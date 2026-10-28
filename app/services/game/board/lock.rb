# frozen_string_literal: true

# Game::Board::Lock runs one board update inside {Game#with_lock},
# against the same {Board} instance the view renders.
#
# Cell actions used to load {Board#cells} before taking the lock, then stamp
# the broadcast with {Time.current} at render time. An update that waited on
# the lock could publish that stale collection under a newer clock, and
# `versioned_replace` would roll every client back to it.
#
# Reload the rendered board inside the lock, advance {Board#version} there,
# and yield the fresh {Cell} from that collection. The version on the way out
# is the snapshot the clients compare.
class Game::Board::Lock
  def self.call(game:, board:, cell:, &)
    new(game:, board:, cell:).call(&)
  end

  def initialize(game:, board:, cell:)
    @game = game
    @board = board
    @cell = cell
  end

  def call
    game.with_lock do
      reload_rendered_board
      fresh_cell = find_fresh_cell
      board.increment!(:version)
      yield(fresh_cell)
    end
  end

  private

  attr_reader :game,
              :board,
              :cell

  def reload_rendered_board
    board.reload
    pin_rendered_board
    board.cells.load
    mark_cells_readonly if Game::Status.over?(game)
  end

  # {Game#with_lock} reloads the Game and drops its cached board. Later reads
  # of {Game#board} would be a different instance, and the view would keep
  # rendering this one. Point the association back at the board we reloaded.
  #
  # {Board#reload} likewise drops the board's cached game. Services that reach
  # the game through the board (e.g. {Board::CheckForVictory}) would then load
  # and end a different Game instance, so {Game#just_ended?} would never be
  # set on the one the controller dispatches from. Point that side back, too.
  def pin_rendered_board
    game.association(:board).tap(&:reset).target = board
    board.association(:game).tap(&:reset).target = game
  end

  def mark_cells_readonly
    board.cells.each(&:readonly!)
  end

  def find_fresh_cell
    cell_id = cell.id
    fresh_cell = board.cells.detect { |candidate| candidate.id == cell_id }
    return fresh_cell if fresh_cell

    raise(
      ActiveRecord::RecordNotFound,
      "#{game.identify} -> #{board.identify} -> Cell[#{cell_id.inspect}]",
    )
  end
end
