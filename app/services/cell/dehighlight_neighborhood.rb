# frozen_string_literal: true

# Cell::DehighlightNeighborhood updates the given {Cell} record, and all
# applicable neighboring {Cell}s to an unhighlighted state.
class Cell::DehighlightNeighborhood
  def self.call(...) = new(...).call

  def initialize(cell)
    @cell = cell
  end

  def call
    return unless revealed?

    unset_highlight_origin
    result_cells = dehighlight_neighboring_cells

    { cell => result_cells }
  end

  private

  attr_reader :cell

  def revealed? = cell.revealed?
  def neighbors = Cell::Neighbors.new(cell:)

  def unset_highlight_origin = cell.unset_highlight_origin

  # @return [Array<Cell>] The Cells that were just highlighted.
  def dehighlight_neighboring_cells
    neighbors.each_with_object(CompactArray.new) { |neighboring_cell, acc|
      acc << dehighlight_neighboring_cell(neighboring_cell)
    }.to_a
  end

  def dehighlight_neighboring_cell(neighboring_cell)
    return unless Cell::State.dehighlightable?(neighboring_cell)

    do_dehighlight_neighboring_cell(neighboring_cell)

    neighboring_cell
  end

  def do_dehighlight_neighboring_cell(neighboring_cell)
    neighboring_cell.update_column(:highlighted, false)
  end
end
