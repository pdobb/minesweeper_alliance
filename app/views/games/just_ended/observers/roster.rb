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
    @sorted_users ||= game.observers.by_joined_at_asc.uniq
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

    def updateable_display_name = View.updateable_display_name(user:)

    def show_user_url
      Router.user_path(user)
    end

    private

    attr_reader :user
  end
end
