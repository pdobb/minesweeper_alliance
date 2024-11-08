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

  def turbo_frame_name = Games::Past::Show.turbo_frame_name

  def cache_key(context:)
    [
      :user,
      game,
      context.mobile? ? :mobile : :web,
    ]
  end

  def content
    Users::Games::Content.new(game:)
  end

  def results
    Games::Past::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
