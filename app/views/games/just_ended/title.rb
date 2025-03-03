# frozen_string_literal: true

# Games::JustEnded::Title represents an expanded identifier/title for just-ended
# {Game}s.
class Games::JustEnded::Title
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

  def engagement_date
    I18n.l(game_started_at.to_date, format: :weekday_comma_date)
  end

  def show_plus_timestamp? = !game_just_ended?

  def time_ago_in_words
    View.precise_time_ago_in_words(game_ended_at)
  end

  def plus_timestamp
    timestamp = Duration.new(game_ended_at..).to_plus_timestamp
    I18n.l(timestamp, format: :minutes_seconds)
  end

  private

  attr_reader :game

  def game_started_at = game.started_at

  def game_just_ended? = game.just_ended?
  def game_ended_at = game.ended_at
end
