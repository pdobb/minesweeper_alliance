# frozen_string_literal: true

# Users::Games::Nav aides in page-level navigation between each of a {User}'s
# past {Game}s.
class Users::Games::Nav
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def breadcrumb_name = View.updateable_display_name(user:)

  def show_close_button? = true
  def close_game_url = Router.user_path(user)

  def previous_game? = !!previous_game
  def previous_game_url = Router.user_game_path(user, previous_game)

  def next_game? = next_game&.over?
  def next_game_url = Router.user_game_path(user, next_game)

  private

  attr_reader :game,
              :user

  def previous_game
    @previous_game ||=
      base_arel.for_created_at(..game.created_at).by_most_recent.take
  end

  def next_game
    @next_game ||=
      base_arel.for_created_at(game.created_at..).by_least_recent.take
  end

  def base_arel
    user.actively_participated_in_games.excluding(game)
  end
end
