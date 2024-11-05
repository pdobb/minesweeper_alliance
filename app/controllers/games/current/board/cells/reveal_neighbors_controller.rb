# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    Cell::RevealNeighbors.(current_context)

    broadcast_changes
    render_updated_game
  end
end
