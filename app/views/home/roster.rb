# frozen_string_literal: true

# Home::Roster represents a simple roster (list) of all participants--both
# active (if applicable) and passive--currently in the War Room (channel).
class Home::Roster
  def self.broadcast_roster_update
    WarRoomChannel.broadcast_update(
      target: turbo_frame_name,
      partial: "home/roster",
      locals: { roster: new })
  end

  def self.turbo_frame_name = :full_roster

  def turbo_frame_name = self.class.turbo_frame_name

  def listings
    Listing.wrap(users)
  end

  private

  def users
    User.for_token(FleetTracker.tokens)
  end

  # Home::Roster::Listing
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
