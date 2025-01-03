# frozen_string_literal: true

# Cell::Reveal is a Service Object for collaborating with a {Game}, {Board}, and
# {Cell} to process a {Cell} "Reveal" event. This involves:
# - "Starting" the {Game} (if it hasn't already been started),
# - Actually calling {Cell#reveal} (of course),
# - "Ending" the {Game} early / in defeat--if the just-revealed {Cell} was a
#   mine,
# - Recursively revealing neighboring {Cell}s--if the just-revealed {Cell} was
#   Blank, and
# - "Ending" the {Game} in victory if all safe {Cell}s on the {Board} have
#   now/just been revealed.
#
# @see Cell::RecursiveReveal
class Cell::Reveal
  include CallMethodBehaviors

  attr_reader :game,
              :board,
              :cell,
              :user

  def initialize(context)
    @game = context.game
    @board = context.board
    @cell = context.cell
    @user = context.user
  end

  # :reek:TooManyStatements

  def call
    return self if already_revealed?

    catch(:return) {
      start_game_if_standing_by
      reveal_cell
      end_game_in_defeat_if_mine_revealed
      recursively_reveal_neighbors_if_revealed_cell_was_blank
      end_game_in_victory_if_all_safe_cells_revealed

      self
    }
  end

  private

  def already_revealed?
    cell.revealed?
  end

  def start_game_if_standing_by
    game.start(seed_cell: cell, user:)
  end

  def reveal_cell
    cell.transaction do
      cell.reveal
      CellRevealTransaction.create_between(user:, cell:)
    end
  end

  def end_game_in_defeat_if_mine_revealed
    return unless cell.mine?

    game.end_in_defeat(user:)
    throw(:return, self)
  end

  def recursively_reveal_neighbors_if_revealed_cell_was_blank
    return unless cell.blank? # rubocop:disable all

    upsertable_attributes_array = Cell::RecursiveReveal.new(cell:).call
    Cell.upsert_all(upsertable_attributes_array)
  end

  def end_game_in_victory_if_all_safe_cells_revealed
    board.check_for_victory(user:)
  end
end
