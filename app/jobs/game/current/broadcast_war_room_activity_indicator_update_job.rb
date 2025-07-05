# frozen_string_literal: true

class Game::Current::BroadcastWarRoomActivityIndicatorUpdateJob < ApplicationJob
  queue_as :default

  def perform
    activity_indicator = Games::Current::ActivityIndicator.new

    Turbo::StreamsChannel.broadcast_replace_to(
      Application::Layout.turbo_stream_name,
      target: activity_indicator.turbo_target,
      attributes: { method: :morph },
      partial: "games/current/activity_indicator",
      locals: { activity_indicator: },
    )
  end
end
