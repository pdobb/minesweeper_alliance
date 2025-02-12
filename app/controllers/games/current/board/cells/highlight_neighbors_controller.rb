# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    updated_cells = cell.soft_highlight_neighbors

    broadcast_updates(updated_cells)
  end
end
