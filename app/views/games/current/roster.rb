# frozen_string_literal: true

# Games::Current::Roster represents a simple roster (list) of all
# participants--both active and passive--currently in the War Room (channel).
class Games::Current::Roster
  def self.broadcast_roster_update
    WarRoomChannel.broadcast_update(
      target: turbo_frame_name,
      partial: "games/current/roster",
      locals: { roster: new })
  end

  def self.turbo_frame_name = :fleet_roster

  def turbo_frame_name = self.class.turbo_frame_name

  def fleet_size = FleetTracker.count

  def listings
    Listing.wrap(users)
  end

  private

  def users
    User.for_token(FleetTracker.tokens)
  end

  # Games::Current::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user)
      @user = user
    end

    def name = user.display_name

    def show_user_url
      Router.user_path(user)
    end

    private

    attr_reader :user
  end
end
