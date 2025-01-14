# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      Cell::RevealNeighbors.(current_context)

      render_updated_game
    end
  end
end
