# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      Cell::ToggleFlag.(cell, user: current_user)
    end

    broadcast_updates(cell)
  end
end
