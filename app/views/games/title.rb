# frozen_string_literal: true

# Games::Title represents an expanded identifier/title for current/past {Game}s.
class Games::Title
  def initialize(game:)
    @game = game
  end

  def game_absolute_url
    Router.game_url(game)
  end

  def title_text = "Copy URL to Clipboard"

  def spam? = game.spam?
  def game_number = game.display_id

  def game_url
    Router.game_path(game)
  end

  def engagement_date
    I18n.l(game_started_at.to_date, format: :weekday_comma_date)
  end

  def engagement_time_range
    View.safe_join([
      I18n.l(game_started_at, format: :hours_minutes_seconds),
      I18n.l(game_ended_at, format: :hours_minutes_seconds),
    ], "–")
  end

  def engagement_date_range_increment?
    engagement_date_range_increment.positive?
  end

  def engagement_date_range_increment
    @engagement_date_range_increment ||=
      (game_ended_at.to_date - game_started_at.to_date).to_i
  end

  def engagement_date_range_increment_title
    View.safe_join([
      "Ended",
      I18n.l(game_ended_at, format: :weekday_comma_date),
      "(#{View.pluralize("day", count: engagement_date_range_increment)}",
      "after start).",
    ], " ")
  end

  private

  attr_reader :game

  def game_started_at = game.started_at
  def game_ended_at = game.ended_at
end
