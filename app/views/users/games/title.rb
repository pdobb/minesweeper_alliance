# frozen_string_literal: true

# Users::Games::Title
class Users::Games::Title < Games::Title
  def initialize(game:, user:)
    super(game:)
    @user = user
  end

  def game_absolute_url
    Router.user_game_url(user, game)
  end

  def game_url
    Router.user_game_path(user, game)
  end

  private

  attr_reader :user
end
