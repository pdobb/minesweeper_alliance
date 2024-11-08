# frozen_string_literal: true

# Games::Users::DutyRoster represents the "Duty Roster" (a list of {User}s that
# participated in a {Game}).
class Games::Users::DutyRoster
  def self.turbo_stream_name(game) = [game, :duty_roster]

  def initialize(game:)
    @game = game
  end

  def turbo_stream_name = self.class.turbo_stream_name(game)

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

    def dom_id = View.dom_id(user)
    def name = user.display_name

    def show_user_url
      Router.user_path(user)
    end

    private

    attr_reader :user,
                :game
  end
end
