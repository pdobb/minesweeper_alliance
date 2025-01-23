# frozen_string_literal: true

# Games::Current::BroadcastFleetUpdatesJob
class Games::Current::BroadcastFleetUpdatesJob < ApplicationJob
  queue_as :default

  def perform
    FleetTracker.prune

    broadcast_fleet_size_update
    broadcast_fleet_roster_update
  end

  private

  def broadcast_fleet_size_update
    WarRoomChannel.broadcast_update(
      target: Games::Current::Status.fleet_size_turbo_update_target,
      html: FleetTracker.count)
  end

  def broadcast_fleet_roster_update
    WarRoomChannel.broadcast_update(
      target: Home::Roster.fleet_roster_turbo_update_target,
      partial: "home/roster",
      locals: { roster: Home::Roster.new(game: Game.current) })
  end
end
