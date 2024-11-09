# frozen_string_literal: true

# Games::Past::Nav handles page-level navigation between past {Game}s.
class Games::Past::Nav
  def initialize(game:)
    @game = game
  end

  def show_close_button? = true
  def close_game_url = Router.games_path

  def previous_game? = !!previous_game
  def previous_game_url = Router.game_path(previous_game)

  def next_game? = next_game&.over?
  def next_game_url = Router.game_path(next_game)

  def show_current_game_button? = true
  def current_game_url = Router.root_path

  private

  attr_reader :game

  def previous_game
    @previous_game ||=
      base_arel.for_created_at(..game.created_at).by_most_recent.take
  end

  def next_game
    @next_game ||=
      base_arel.for_created_at(game.created_at..).by_least_recent.take
  end

  def base_arel
    Game.excluding(game)
  end
end
