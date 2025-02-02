# frozen_string_literal: true

class Game::Current::BroadcastFleetRemovalJob < ApplicationJob
  queue_as :default

  def perform(token)
    return unless FleetTracker.missing_or_expired?(token)

    broadcast_remove_user(token)
    broadcast_fleet_size_update
  end

  private

  def broadcast_remove_user(token)
    user = find_user(token)
    target = Home::Roster::Listing.turbo_target(user:)
    WarRoomChannel.broadcast_remove(target:)
  end

  def find_user(token) = User.find(token)

  def broadcast_fleet_size_update
    FleetTracker.broadcast_fleet_size_update
  end
end
