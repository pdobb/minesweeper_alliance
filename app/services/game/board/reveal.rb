# frozen_string_literal: true

# :reek:TooManyInstanceVariables

# Game::Board::Reveal is a Service Object for collaborating with a {Game},
# {Board}, and {Cell} to process a {Cell} "Reveal" event. This involves:
# - "Starting" the {Game} (if it hasn't already been started),
# - Actually calling {Cell#reveal} (of course),
# - "Ending" the {Game} early / in defeat--if the just-revealed {Cell} was a
#   mine,
# - Recursively revealing neighboring {Cell}s--if the just-revealed {Cell} was
#   Blank, and
# - "Ending" the {Game} in victory if all safe {Cell}s on the {Board} have
#   now/just been revealed.
class Game::Board::Reveal
  def self.call(...) = new(...).call

  def initialize(context:)
    @game = context.game
    @board = context.board
    @cell = context.cell
    @user = context.user
  end

  def call
    catch(:return) {
      perform_action
      self
    }
  end

  private

  attr_reader :game,
              :board,
              :cell,
              :user

  def perform_action
    Game::Board::Lock.(game:, board:, cell:) do |fresh_cell|
      @cell = fresh_cell
      reveal_fresh_cell unless already_revealed?
    end
  end

  def already_revealed?
    cell.revealed?
  end

  def reveal_fresh_cell
    start_game_if_standing_by
    reveal_cell
    end_game_in_defeat_if_mine_revealed
    recursively_reveal_neighbors_if_revealed_cell_was_blank
    end_game_in_victory_if_all_safe_cells_revealed
  end

  def start_game_if_standing_by
    return unless game.status_standing_by?

    Game::Start.(game:, seed_cell: cell, user:)
  end

  def reveal_cell
    cell.transaction do
      CellRevealTransaction.create_between(user:, cell:)
      ParticipantTransaction.activate_between(user:, game:)
      Cell::Reveal.(cell)
    end
  end

  def end_game_in_defeat_if_mine_revealed
    return unless cell.mine?

    Game::EndInDefeat.(game:, user:)
    throw(:return, self)
  end

  def recursively_reveal_neighbors_if_revealed_cell_was_blank
    return unless Cell::State.blank?(cell) # rubocop:disable all

    upsertable_attributes_array = Game::Board::RecursiveReveal.(cell)
    Cell.upsert_all(upsertable_attributes_array)
  end

  def end_game_in_victory_if_all_safe_cells_revealed
    Board::CheckForVictory.(board:, user:)
  end
end
