# frozen_string_literal: true

# Cell::HighlightNeighborhood updates the given {Cell} record, and all
# applicable neighboring {Cell}s to a highlighted state.
class Cell::HighlightNeighborhood
  def self.call(...) = new(...).call

  def initialize(cell)
    @cell = cell
  end

  def call
    return unless revealed?

    result_cells =
      cell.transaction {
        set_highlight_origin
        highlight_neighboring_cells
      }

    { cell => result_cells }
  end

  private

  attr_reader :cell

  def revealed? = cell.revealed?
  def neighbors = Cell::Neighbors.new(cell:)

  def set_highlight_origin = cell.update_column(:highlight_origin, true)

  # @return [Array<Cell>] The Cells that were just highlighted.
  def highlight_neighboring_cells
    neighbors.each_with_object(CompactArray.new) { |neighboring_cell, acc|
      acc << highlight_neighboring_cell(neighboring_cell)
    }.to_a
  end

  def highlight_neighboring_cell(neighboring_cell)
    return unless Cell::State.highlightable?(neighboring_cell)

    do_highlight_neighboring_cell(neighboring_cell)

    neighboring_cell
  end

  def do_highlight_neighboring_cell(neighboring_cell)
    neighboring_cell.update_column(:highlighted, true)
  end
end
