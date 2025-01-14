# frozen_string_literal: true

# Games::Past::Status represents the status (victory vs defeat) for past
# {Game}s.
class Games::Past::Status
  def initialize(game:)
    @game = game
  end

  def game_status_css
    if game_ended_in_defeat?
      %w[text-red-700 dark:text-red-600]
    elsif game_ended_in_victory?
      %w[text-green-700 dark:text-green-600]
    end
  end

  def game_status = game.status
  def game_status_mojis = past_game.status_mojis

  private

  attr_reader :game

  def game_ended_in_defeat? = game.ended_in_defeat?
  def game_ended_in_victory? = game.ended_in_victory?

  def past_game = @past_game ||= Games::Past.new(game:)
end
