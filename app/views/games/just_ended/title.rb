# frozen_string_literal: true

# Games::JustEnded::Title represents an expanded identifier/title for just-ended
# {Game}s.
class Games::JustEnded::Title
  def initialize(game:)
    @game = game
  end

  def game_absolute_url
    Router.game_url(game)
  end

  def title_text = "Copy URL to Clipboard"

  def game_number = game.display_id

  def game_url
    Router.game_path(game)
  end

  def engagement_date
    I18n.l(game_started_at.to_date, format: :weekday_comma_date)
  end

  def elapsed_time
    Games::Past::ElapsedTime.new(game:)
  end

  private

  attr_reader :game

  def game_started_at = game.started_at
end
