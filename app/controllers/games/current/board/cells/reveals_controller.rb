# frozen_string_literal: true

class Games::Current::Board::Cells::RevealsController < ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    dispatch_action.call { |dispatch|
      dispatch.on_game_start { generate_just_started_game_turbo_stream_updates }
      perform_action
      dispatch.call
    }
  end

  private

  def dispatch_action
    @dispatch_action ||=
      Games::Current::Board::Cells::DispatchAction.new(context: self)
  end

  def perform_action
    Cell::Reveal.(context:)
  end

  def generate_just_started_game_turbo_stream_updates
    [
      generate_game_status_turbo_stream_update,
      generate_elapsed_time_turbo_stream_update,
      (generate_mine_cell_indicators_turbo_stream_updates if App.debug?),
    ]
  end

  def generate_game_status_turbo_stream_update
    turbo_stream.replace(
      Games::Current::Status.game_status_turbo_target,
      html: Games::Current::Status.new(game:).game_status_with_emoji)
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

  def generate_mine_cell_indicators_turbo_stream_updates
    Cell::TurboStream::Morph.wrap_and_call(board.mine_cells, turbo_stream:)
  end
end
