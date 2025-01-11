# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Roster represents a list of {User}s
# that actively participated in a just-ended {Game}.
#
# @see Games::Past::ActiveParticipants::Roster
class Games::JustEnded::ActiveParticipants::Roster
  def self.turbo_stream_name(game) = [game, :active_participants_roster]

  def initialize(game:)
    @game = game
  end

  def turbo_stream_name = self.class.turbo_stream_name(game)

  def listings
    Listing.wrap(sorted_users, game:)
  end

  private

  attr_reader :game

  def sorted_users
    User.for_game(game)
  end

  # Games::JustEnded::ActiveParticipants::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user, game:)
      @user = user
      @game = game
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
