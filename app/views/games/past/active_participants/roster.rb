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
    Listing.wrap(sorted_users, game:, game_ender:)
  end

  private

  attr_reader :game

  def sorted_users
    game.active_participants.by_participated_at_asc.uniq
  end

  def game_ender
    game.game_end_transaction.user
  end

  # Games::Past::ActiveParticipants::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user, game:, game_ender:)
      @user = user
      @game = game
      @is_game_ender = user == game_ender
    end

    def updateable_display_name = View.updateable_display_name(user:)

    def show_user_url
      Router.user_path(user)
    end

    def tripped_mine? = game_ender? && game.ended_in_defeat?
    def cleared_board? = game_ender? && game.ended_in_victory?

    private

    attr_reader :user,
                :game

    def game_ender? = @is_game_ender
  end
end
