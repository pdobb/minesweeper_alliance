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

  def to_param = self.class.turbo_stream_name(game)

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

  # Games::JustEnded::ActiveParticipants::Roster::Listing
  class Listing
    include WrapMethodBehaviors

    def initialize(user, game:, game_ender:)
      @user = user
      @game = game
      @is_game_ender = user == game_ender
    end

    def show_current_user_indicator?(current_user)
      current_user.not_a_signer? && user == current_user
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
