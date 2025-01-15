# frozen_string_literal: true

# Games::Current::BroadcastRosterUpdateJob
class Games::Current::BroadcastRosterUpdateJob < ApplicationJob
  queue_as :default

  def perform
    FleetTracker.tap(&:prune)

    broadcast_fleet_size_update
    broadcast_roster_update
  end

  private

  def broadcast_fleet_size_update
    Games::Current::Status.broadcast_fleet_size_update
  end

  def broadcast_roster_update
    Home::Roster.broadcast_roster_update
  end
end
