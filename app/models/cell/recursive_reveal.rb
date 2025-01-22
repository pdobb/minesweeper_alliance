# frozen_string_literal: true

# Cell::RecursiveReveal is a Service Module for revealing the given {Cell} and
# then recursively revealing neighboring {Cell}s--if the just-revealed {Cell}
# was Blank (see {Cell#blank?}).
#
# While {Cell#reveal} is called on every Cell, what's returned from this service
# is just the Set of {Cell}s where {Cell#revealed?} actually changed to `true`.
#
# Notes:
# - We don't want or need to spend time checking on {Game#status} or current
#   {Board} state while recursing. This is because we only get to here by
#   revealing a blank {Cell} in the first place--which is always safe to reveal
#   neighbors on.
# - We purposefully use a module instead of a class because this is recursion
#   and, so, it's actually worth trimming down the size of the call stack.
module Cell::RecursiveReveal
  def self.call(cell)
    unrevealed_neighboring_cells(cell).inject(Set.new) { |acc, neighboring_cell|
      next acc unless (revealed_cell = neighboring_cell.soft_reveal)

      acc << revealed_cell.upsertable_attributes
      acc |= call(revealed_cell) if revealed_cell.blank?
      acc
    }
  end

  # We just go ahead and reveal any incorrectly flagged {Cell}s here, as there
  # is no good reason not to. And not doing so creates awkward gaps in the Game
  # board.
  def self.unrevealed_neighboring_cells(cell)
    cell.neighbors.reject(&:revealed?)
  end
end
