# frozen_string_literal: true

# Game::Current::BroadcastFleetRemovalJob
class Game::Current::BroadcastFleetRemovalJob < ApplicationJob
  queue_as :default

  def perform(token)
    return unless FleetTracker.expired?(token)

    broadcast_remove_user(token)
    broadcast_fleet_size_update
  end

  private

  def broadcast_remove_user(token)
    user = find_user(token)
    target = Home::Roster::Listing.turbo_target(user:)
    WarRoomChannel.broadcast_remove(target:)
  end

  def find_user(token) = User.for_token(token).take!

  def broadcast_fleet_size_update
    FleetTracker.broadcast_fleet_size_update
  end
end
