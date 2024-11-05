# frozen_string_literal: true

# Games::Current::Nav represents page-level navigation away from the current
# {Game} (to the most recent past {Game}).
class Games::Current::Nav
  def previous_game? = !!previous_game

  def previous_game_url
    Router.game_path(previous_game)
  end

  private

  attr_reader :current_game

  def previous_game
    @previous_game ||= Game.for_game_over_statuses.last
  end
end
