# frozen_string_literal: true

# Games::Current::Status represents the status (Standing By vs Sweep In
# Progress) for the current {Game}.
class Games::Current::Status
  def initialize(current_game:)
    @current_game = current_game
  end

  def game_status_css
    if game_ended_in_defeat?
      %w[text-red-700 dark:text-red-600]
    elsif game_ended_in_victory?
      %w[text-green-700 dark:text-green-600]
    end
  end

  def game_status = current_game.status

  def game_status_emoji
    game_standing_by? ? Emoji.anchor : Emoji.ship
  end

  def players_count(roster = DutyRoster)
    [roster.count, 1].max
  end

  private

  attr_reader :current_game

  def game_standing_by? = current_game.status_standing_by?
  def game_ended_in_defeat? = current_game.ended_in_defeat?
  def game_ended_in_victory? = current_game.ended_in_victory?
end
