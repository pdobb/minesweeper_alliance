# frozen_string_literal: true

# Users::Games::Nav aides in page-level navigation between each of a {User}'s
# past {Game}s.
class Users::Games::Nav < Games::Past::Nav
  def initialize(game:, user:)
    super(game:)
    @user = user
  end

  def show_close_button? = true
  def close_game_url = Router.user_path(user)
  def previous_game_url = Router.user_game_path(user, previous_game)
  def next_game_url = Router.user_game_path(user, next_game)
  def show_current_game_button? = false

  private

  attr_reader :user

  def base_arel
    user.games.excluding(game)
  end
end
