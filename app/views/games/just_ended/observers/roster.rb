# frozen_string_literal: true

# Games::JustEnded::Observers::Roster represents a list of {User}s that only
# passively participated in a just-ended {Game}.
#
# @see Games::Past::Observers::Roster
class Games::JustEnded::Observers::Roster
  def initialize(game:)
    @game = game
  end

  def listings? = sorted_users.any?

  def listings
    Listing.wrap(sorted_users)
  end

  private

  attr_reader :game

  def sorted_users
    @sorted_users ||= User.for_game_as_observer_by_joined_at_asc(game)
  end

  # Games::JustEnded::Observers::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user)
      @user = user
    end

    def user?(current_user)
      current_user == user
    end

    def name = user.display_name

    def show_user_url
      Router.user_path(user)
    end

    private

    attr_reader :user
  end
end
