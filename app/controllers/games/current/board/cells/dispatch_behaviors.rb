# frozen_string_literal: true

# Games::Current::Board::Cells::DispatchBehaviors
module Games::Current::Board::Cells::DispatchBehaviors
  extend ActiveSupport::Concern

  private

  def generate_game_update_action
    content = Games::Current::Board::Content.new(board:)
    html =
      render_to_string(
        partial: "games/current/board/content",
        locals: { content: },
      )

    turbo_stream_actions <<
      turbo_stream.action(
        :versioned_replace,
        content.turbo_target,
        html,
        method: :morph,
      )
  end
end
