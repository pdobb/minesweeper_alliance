# frozen_string_literal: true

# Games::Title represents an expanded identifier/title for current/past {Game}s.
class Games::Title
  def initialize(game:)
    @game = game
  end

  def game_number = game.display_id

  def game_absolute_url
    Router.game_url(game)
  end

  def game_url
    Router.game_path(game)
  end

  def game_engagement_date
    I18n.l(game_ended_at.to_date, format: :weekday_comma_date)
  end

  def game_engagement_time_range
    View.safe_join(
      [
        I18n.l(game_started_at, format: :hours_minutes_seconds),
        I18n.l(game_ended_at, format: :hours_minutes_seconds),
      ],
      "&ndash;".html_safe)
  end

  private

  attr_reader :game

  def game_started_at = game.started_at
  def game_ended_at = game.ended_at
end
