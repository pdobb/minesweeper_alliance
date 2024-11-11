# frozen_string_literal: true

# Users::Games::Show represents past {Game}s in the context of a participating
# player ({User}).
class Users::Games::Show
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def display_name = user.display_name
  def game_number = game.display_id

  def nav
    Users::Games::Nav.new(game:, user:)
  end

  def container
    Users::Games::Container.new(game:, user:)
  end

  private

  attr_reader :game,
              :user
end
