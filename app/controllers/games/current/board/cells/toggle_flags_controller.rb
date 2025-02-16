# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  rate_limit to: 3, within: 1.second

  def create
    response_generator << Cell::ToggleFlag.(cell:, user: current_user, game:)
    response_generator.call {
      turbo_stream.update(
        Games::Current::Board::Header.placed_flags_count_turbo_target,
        board.flags_count)
    }
  end

  private

  def response_generator
    @response_generator ||=
      Games::Current::Board::Cells::GenerateActiveResponse.new(context: self)
  end
end
