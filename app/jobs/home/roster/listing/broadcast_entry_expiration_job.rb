# frozen_string_literal: true

class Home::Roster::Listing::BroadcastEntryExpirationJob < ApplicationJob
  queue_as :default

  def perform(token)
    entry = find_entry(token)
    return unless entry&.expired?

    FleetTracker.broadcast_fleet_entry_update(entry:)
  end

  private

  def find_entry(token) = FleetTracker.find(token)
end
