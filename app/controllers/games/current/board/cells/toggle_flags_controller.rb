# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      updated_cell = Cell::ToggleFlag.(cell, user: current_user)

      WarRoomChannel.broadcast(
        Cell::TurboStream::Morph.(updated_cell, turbo_stream:))
    end

    head(:no_content)
  end
end
