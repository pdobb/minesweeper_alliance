# frozen_string_literal: true

# Games::Past::ActiveParticipants::Roster represents a list of {User}s that
# participated in a past {Game}.
#
# @see Games::JustEnded::ActiveParticipants::Roster
class Games::Past::ActiveParticipants::Roster
  def initialize(game:)
    @game = game
  end

  def listings
    Listing.wrap(sorted_users, game:)
  end

  private

  attr_reader :game

  def sorted_users
    User.for_game_as_active_participant(game).by_participated_at_asc
  end

  # Games::Past::ActiveParticipants::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user, game:)
      @user = user
      @game = game
    end

    def name = user.display_name

    def show_user_url
      Router.user_path(user)
    end

    private

    attr_reader :user,
                :game
  end
end
