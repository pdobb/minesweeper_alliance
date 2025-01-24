# frozen_string_literal: true

# Home::Roster represents a simple roster (list) of all participants--both
# active and passive--currently in the War Room channel.
class Home::Roster
  def self.turbo_target = "fleetRoster"

  def initialize(game:)
    @game = game
  end

  def turbo_target = self.class.turbo_target

  def listings? = users.any?

  def listings
    PageLoadListing.wrap(users, game:)
  end

  private

  attr_reader :game

  def users
    User.for_token(FleetTracker.tokens)
  end

  # Home::Roster::PageLoadListing is a {Home::Roster::Listing} that stands in
  # for the initial page load while bowing out for Turbo Stream updates.
  #
  # As {Users} subscribe/unsubscribe from the WarRoom channel, they are are
  # automatically added/removed from the Roster via Turbo Stream
  # updates--initiated by the {FleetTracker}. However, we still need to render
  # the current roster (based on {FleetTracker.tokens}) on the  initial page
  # load, and for subsequent page reloads.
  class PageLoadListing < Home::Roster::Listing
    def initialize(user, game:)
      super(user:, active: nil)
      @game = game
    end

    private

    attr_reader :game

    def active?
      user.active_participant_in?(game:)
    end
  end
end
