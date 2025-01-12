# frozen_string_literal: true

# BroadcastSubscriptionCountUpdateJob
class BroadcastSubscriptionCountUpdateJob < ApplicationJob
  queue_as :default

  def perform(stream_name:)
    Games::Current::Container.broadcast_players_count_update(
      stream_name:, count: FleetTracker.count)
  end
end
