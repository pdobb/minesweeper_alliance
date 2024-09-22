# frozen_string_literal: true

# Games::Boards::Cells::RecursiveReveal is a Service Object for revealing the
# given {Cell} and then recursively revealing neighboring {Cell}s--if the {Cell}
# we just revealed was {Cell#blank?}.
#
# Notes:
# - We don't want or need to spend time checking on {Game#status} or {Board}
#   state while recursing. We only get to here by revealing a blank {Cell} in
#   the first place, which is always safe to reveal neighbors on.
# - We purposefully don't `include CallMethodBehaviors` here, because this is
#   recursion an it's actually worth reducing the call stack size.
#     So instead of:
#       RecursiveReveal.call -> RecursiveReveal.new(..).call -> #on_call
#     We optimize to just:
#       RecursiveReveal.new(...).call -> #call
class Games::Boards::Cells::RecursiveReveal
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
