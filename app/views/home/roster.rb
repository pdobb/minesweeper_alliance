# frozen_string_literal: true

# Home::Roster represents a simple roster (list) of all participants--both
# active and passive--currently in the War Room channel. Note, this list is
# meant to be entirely curated by {FleetTracker}, with no actual Database
# involvement.
class Home::Roster
  def self.turbo_target = "fleetRoster"

  def initialize(game:)
    @game = game
  end

  def turbo_target = self.class.turbo_target

  def listings? = entries.any?

  def listings
    Home::Roster::Listing.wrap(entries)
  end

  private

  def entries = @entries ||= FleetTracker.entries
end
