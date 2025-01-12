# frozen_string_literal: true

# BroadcastCurrentFleetSizeJob
class BroadcastCurrentFleetSizeJob < ApplicationJob
  queue_as :default

  def perform(stream_name = WarRoomChannel::STREAM_NAME)
    Games::Current::Container.broadcast_current_fleet_size(
      stream_name:,
      count: FleetTracker.tap(&:prune).count)
  end
end
