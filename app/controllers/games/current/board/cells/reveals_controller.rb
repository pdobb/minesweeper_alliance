# frozen_string_literal: true

class Games::Current::Board::Cells::RevealsController < ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  before_action :require_participant

  def create
    updated_cells = Cell::Reveal.(context).updated_cells

    broadcast_updates(updated_cells) {
      just_started_game_turbo_stream_updates if game.just_started?
    }
  end

  private

  def just_started_game_turbo_stream_updates
    [
      game_status_turbo_stream_update,
      elapsed_time_turbo_stream_update,
      (mine_cell_indicators_turbo_stream_updates if App.debug?),
    ]
  end

  def game_status_turbo_stream_update
    turbo_stream.replace(
      Games::Current::Status.game_status_turbo_update_target,
      html: Games::Current::Status.new(game:).game_status_with_emoji)
  end

  def elapsed_time_turbo_stream_update
    turbo_stream.replace(
      Games::Board::ElapsedTime.turbo_update_target,
      partial: "games/current/board/header/elapsed_time",
      locals: {
        elapsed_time: Games::Board::ElapsedTime.new(game:),
      },
      method: :morph)
  end

  def mine_cell_indicators_turbo_stream_updates
    Cell::TurboStream::Morph.wrap_and_call(board.mine_cells, turbo_stream:)
  end
end
