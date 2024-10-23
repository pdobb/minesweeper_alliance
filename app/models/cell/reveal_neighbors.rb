# frozen_string_literal: true

# Cell::RevealNeighbors is a Service Object for collaborating with a {Game},
# {Board}, and {Cell} to process a {Cell} "Reveal Neighbors" event (a.k.a.
# "chording"). In order for processing to proceed:
# - The given, originating {Cell} must have been previously revealed, and
# - The number of flagged neighboring {Cell}s must match the given {Cell}'s
#   {Cell#value}.
#
# This service is a convenience. We're saving the player time by just going
# ahead and revealing all of the non-flagged (and non-revealed) neighboring
# cells of the given, originating {Cell}. Also, if doing so reveals a Blank
# {Cell}, then we'll recursively reveal its neighboring {Cell}s, as per usual.
#
# Whether we end up revealing any neighboring {Cell}s or not, we will also
# always need to dehighlight any highlighted, neighboring {Cell}s as per our
# game play rules.
# - We take care of this here, in case we don't end up revealing any
#   neighbors.
# - If neighbors are revealed, however, {Cell#reveal} takes care of the
#   de-highlighting of those {Cell}s for us.
#
# Notes:
# - If this operation results in a win or loss, we need to capture that.
# - Revealing neighbors doesn't guarantee success. If any of the flags are
#   incorrectly placed a mine could still go off!
#
# @see Cell::RecursiveReveal
class Cell::RevealNeighbors
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

  def on_call
    return self if cell.unrevealed?

    catch(:return) {
      reveal_or_dehighlight_neighbors
      end_game_in_victory_if_all_safe_cells_revealed

      self
    }
  end

  private

  def reveal_or_dehighlight_neighbors
    if cell.neighboring_flags_count_matches_value?
      reveal_neighbors
    else
      cell.dehighlight_neighbors
    end
  end

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
    neighboring_cell.reveal

    end_in_defeat if neighboring_cell.mine?
  end

  def end_in_defeat
    game.end_in_defeat
    throw(:return, self)
  end

  def recursively_reveal_neighbors(neighboring_cell)
    upsertable_attributes_array =
      Cell::RecursiveReveal.new(cell: neighboring_cell).call
    Cell.upsert_all(upsertable_attributes_array)
  end

  def end_game_in_victory_if_all_safe_cells_revealed
    board.check_for_victory
  end
end
