# frozen_string_literal: true

# Home::Roster represents a simple roster (list) of all participants--both
# active (if applicable) and passive--currently in the War Room (channel).
class Home::Roster
  def self.fleet_roster_turbo_update_target = "fleetRoster"

  def initialize(game:)
    @game = game
  end

  def fleet_roster_turbo_update_target
    self.class.fleet_roster_turbo_update_target
  end

  def listings? = users.any?

  def listings
    Listing.wrap(users, game:)
  end

  private

  attr_reader :game

  def users
    User.for_token(FleetTracker.tokens)
  end

  # Home::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def self.participation_status_turbo_update_target(user:)
      View.dom_id(user, :participation_status)
    end

    def initialize(user, game:)
      @user = user
      @game = game
    end

    def turbo_update_id = View.dom_id(user)
    def name = user.display_name

    def show_user_url
      Router.user_path(user)
    end

    def participation_status_turbo_update_target
      self.class.participation_status_turbo_update_target(user:)
    end

    def active_participant?
      return false unless game

      user.active_participant?(game)
    end

    private

    attr_reader :user,
                :game
  end
end
