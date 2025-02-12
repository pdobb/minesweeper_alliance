# frozen_string_literal: true

class Games::Current::Board::Cells::DehighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    updated_cells = cell.highlightable_neighbors

    broadcast_updates(updated_cells)
  end
end
