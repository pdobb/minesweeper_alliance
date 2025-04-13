# frozen_string_literal: true

# Games::Past::ActiveParticipants::Roster::Listing represents an active
# participant ({User}) roster listing/entry for past {Game}s.
class Games::Past::ActiveParticipants::Roster::Listing
  include WrapMethodBehaviors

  def initialize(user, context:)
    @user = user
    @context = context
  end

  def updateable_display_name = View.updateable_display_name(user:)

  def show_user_url
    Router.user_path(user)
  end

  def show_game_participation_indicators?
    context.show_game_participation_indicators?
  end

  def created_game? = context.game_creator?(user)
  def started_game? = context.game_starter?(user)
  def tripped_mine? = game_ended_in_defeat? && game_ender?
  def cleared_board? = game_ended_in_victory? && game_ender?

  private

  attr_reader :user,
              :context

  def game = context.game
  def game_ended_in_defeat? = Game::Status.ended_in_defeat?(game)
  def game_ended_in_victory? = Game::Status.ended_in_victory?(game)
  def game_ender? = context.game_ender?(user)
end
