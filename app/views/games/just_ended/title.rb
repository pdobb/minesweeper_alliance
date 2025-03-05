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

  def elapsed_time
    Games::JustEnded::ElapsedTime.new(ended_at: game_ended_at)
  end

  private

  attr_reader :game

  def game_started_at = game.started_at
  def game_ended_at = game.ended_at
end
