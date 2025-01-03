# frozen_string_literal: true

# Cell::RecursiveReveal is a Service Object for revealing the given {Cell} and
# then recursively revealing neighboring {Cell}s--if the just-revealed {Cell}
# was Blank (see {Cell#blank?}).
#
# Notes:
# - We don't want or need to spend time checking on {Game#status} or current
#   {Board} state while recursing. This is because we only get to here by
#   revealing a blank {Cell} in the first place--which is always safe to reveal
#   neighbors on.
# - We purposefully don't `include CallMethodBehaviors` here, because this is
#   recursion and it's actually worth trimming down the call stack size.
#   So instead of:
#     RecursiveReveal.call -> RecursiveReveal.new(..).call -> #call
#   We optimize this to just:
#     RecursiveReveal.new(...).call -> #call
#
# @see Cell::Reveal
class Cell::RecursiveReveal
  attr_reader :cell

  def initialize(cell:)
    @cell = cell
  end

  def call
    unrevealed_neighboring_cells.inject(Set.new) do |acc, neighboring_cell|
      acc << reveal(neighboring_cell).upsertable_attributes

      if neighboring_cell.blank? # Recurse!
        acc |= self.class.new(cell: neighboring_cell).call
      end

      acc
    end
  end

  private

  # We just go ahead and reveal any incorrectly flagged {Cell}s here, as there
  # is no good reason not to. Also, not doing so creates awkward gaps in
  # the recursion.
  def unrevealed_neighboring_cells
    cell.neighbors.reject(&:revealed?)
  end

  def reveal(neighboring_cell)
    neighboring_cell.soft_reveal
  end
end
