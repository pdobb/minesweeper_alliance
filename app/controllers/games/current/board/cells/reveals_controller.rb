# frozen_string_literal: true

class Games::Current::Board::Cells::RevealsController < ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    dispatch_action.call { |dispatch|
      dispatch.on_game_start { generate_just_started_game_turbo_stream_updates }
      perform_action
      dispatch.call
    }
  rescue Games::Current::Board::Cells::DispatchAction::GameOverError
    render(turbo_stream: turbo_stream.refresh)
  end

  private

  def dispatch_action
    @dispatch_action ||=
      Games::Current::Board::Cells::DispatchAction.new(context: self)
  end

  def perform_action
    Game::Board::Reveal.(context: action_context)
  end

  def generate_just_started_game_turbo_stream_updates
    [
      generate_game_status_turbo_stream_update,
      generate_elapsed_time_turbo_stream_update,
    ]
  end

  def generate_game_status_turbo_stream_update
    turbo_stream.replace(
      Games::Current::Status.game_status_turbo_target,
      html: Games::Current::Status.new(game:).to_s)
  end

  def generate_elapsed_time_turbo_stream_update
    turbo_stream.replace(
      Games::Board::ElapsedTime.turbo_target,
      partial: "games/current/board/header/elapsed_time",
      locals: {
        elapsed_time: Games::Board::ElapsedTime.new(game:),
      },
      method: :morph)
  end
end
