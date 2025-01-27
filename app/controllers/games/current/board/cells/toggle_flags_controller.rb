# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    Cell::ToggleFlag.(cell:, user: current_user, game:)

    broadcast_updates(cell) {
      turbo_stream.update("placedFlagsCount", board.flags_count)
    }
  end
end
