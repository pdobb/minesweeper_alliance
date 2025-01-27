# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    updated_cells =
      safe_perform_game_action {
        cell.soft_highlight_neighbors
      }
    return if performed?

    broadcast_updates([cell, updated_cells])
  end
end
