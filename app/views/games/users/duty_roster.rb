# frozen_string_literal: true

# Games::Users::DutyRoster is a View Model for servicing the "Duty Roster"
# (a list of {User}s that participated in a {Game}) view template.
#
# @see Games::Results
class Games::Users::DutyRoster
  def initialize(game:)
    @game = game
  end

  def turbo_stream_name
    [game, :duty_roster]
  end

  def count
    game.users.size
  end

  def listings
    Listing.wrap(game.users, game:)
  end

  private

  attr_reader :game

  # Games::Users::DutyRoster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user, game:)
      @user = user
      @game = game
    end

    def turbo_frame_name
      [user, :duty_roster_listing]
    end

    def user?(current_user)
      current_user == user
    end

    def dom_id(helpers:)
      helpers.dom_id(user)
    end

    def name
      user.display_name
    end

    def show_user_url(router = RailsRouter.instance)
      router.user_path(user)
    end

    private

    attr_reader :user,
                :game
  end
end
