# frozen_string_literal: true

# :reek:TooManyInstanceVariables

# Cell::RevealNeighbors is a Service Object for collaborating with a {Game},
# {Board}, and {Cell} to process a {Cell} "Reveal Neighbors" event (a.k.a.
# "chording"). Prerequisites for processing:
# - The given, originating {Cell} must have been previously revealed, and
# - The number of flagged neighboring {Cell}s must match the given {Cell}'s
#   {Cell#value}.
#
# In the grand scheme this service is basically just a convenience. i.e. We're
# saving the player time by just going ahead and revealing all of the
# non-flagged (and non-revealed) neighboring {Cell}s of the given, originating
# {Cell}. Also, if doing so reveals a Blank {Cell}, then we'll recursively
# reveal its neighboring {Cell}s, as per usual.
#
# Notes:
# - If this operation results in a Game Win or Loss, we need to capture that.
# - Revealing neighbors doesn't guarantee success. If any of the flags are
#   incorrectly placed a mine could still go off!
#
# @see Cell::RecursiveReveal
class Cell::RevealNeighbors
  include CallMethodBehaviors

  attr_reader :updated_cells

  def initialize(context)
    @game = context.game
    @board = context.board
    @cell = context.cell
    @user = context.user
    @updated_cells = []
  end

  def call
    return self if cell.unrevealed?

    catch(:return) {
      reveal_neighbors
      end_game_in_victory_if_all_safe_cells_revealed

      self
    }
  end

  private

  attr_reader :game,
              :board,
              :cell,
              :user

  def reveal_neighbors
    return if revealable_neighboring_cells.none?

    cell.transaction do
      CellChordTransaction.create_between(user:, cell:)

      revealable_neighboring_cells.each do |neighboring_cell|
        reveal_neighbor(neighboring_cell)
      end
    end
  end

  def revealable_neighboring_cells
    cell.neighbors.select(&:can_be_revealed?)
  end

  def reveal_neighbor(neighboring_cell)
    reveal(neighboring_cell)
    recursively_reveal_neighbors(neighboring_cell) if neighboring_cell.blank?
  end

  # :reek:FeatureEnvy
  def reveal(neighboring_cell)
    push(neighboring_cell.reveal)

    end_in_defeat(user:) if neighboring_cell.mine?
  end

  def end_in_defeat(user:)
    game.end_in_defeat(user:)
    throw(:return, self)
  end

  def recursively_reveal_neighbors(neighboring_cell)
    upsertable_attributes_array = Cell::RecursiveReveal.(neighboring_cell)
    result = Cell.upsert_all(upsertable_attributes_array)

    push(Cell.for_id(result.pluck("id")))
  end

  def end_game_in_victory_if_all_safe_cells_revealed
    board.check_for_victory(user:)
  end

  def push(cell)
    updated_cells.concat(Array.wrap(cell))
  end
end
