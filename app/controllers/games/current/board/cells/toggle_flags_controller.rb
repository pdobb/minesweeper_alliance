# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  rate_limit to: 3, within: 1.second

  def create
    dispatch_action.call { |dispatch|
      dispatch.(perform_action)
      dispatch << generate_placed_flags_count_turbo_stream_update
    }
  end

  private

  def dispatch_action
    @dispatch_action ||=
      Games::Current::Board::Cells::DispatchAction.new(context: self)
  end

  def perform_action
    Cell::ToggleFlag.(context:)
  end

  def generate_placed_flags_count_turbo_stream_update
    turbo_stream.update(
      Games::Current::Board::Header.placed_flags_count_turbo_target,
      board.flags_count)
  end
end
