# frozen_string_literal: true

# Games::Current::BroadcastRosterUpdateJob
class Games::Current::BroadcastRosterUpdateJob < ApplicationJob
  queue_as :default

  def perform(stream_name = WarRoomChannel::STREAM_NAME)
    FleetTracker.tap(&:prune)

    broadcast_fleet_size_update(stream_name:)
    broadcast_roster_update(stream_name:)
  end

  private

  def broadcast_fleet_size_update(stream_name:)
    Games::Current::Status.broadcast_fleet_size_update(
      stream_name:)
  end

  def broadcast_roster_update(stream_name:)
    Games::Current::Roster.broadcast_roster_update(
      stream_name:,
      current_game:)
  end

  def current_game
    Game.current
  end
end
