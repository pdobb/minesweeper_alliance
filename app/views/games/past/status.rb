# frozen_string_literal: true

# Games::Past::Status represents the status (victory vs defeat) for past
# {Game}s.
class Games::Past::Status
  def initialize(game:)
    @game = game
  end

  def css
    if ended_in_defeat?
      %w[text-red-700 dark:text-red-600]
    elsif ended_in_victory?
      %w[text-green-700 dark:text-green-600]
    end
  end

  def to_s
    game.status
  end

  def statusmojis = past_game_view.statusmojis

  private

  attr_reader :game

  def ended_in_defeat? = game.ended_in_defeat?
  def ended_in_victory? = game.ended_in_victory?

  def past_game_view = @past_game_view ||= Games::Past.new(game:)
end
