# frozen_string_literal: true

# Games::Results is a View Model for displaying end-of-{Game} results (and
# collect signatures, show stats, show Duty Roster, etc.).
class Games::Results
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def signature
    Games::Users::Signature.new(game:, user:)
  end

  def game_engagement_date
    I18n.l(game_ended_at.to_date, format: :weekday_comma_date)
  end

  def game_engagement_time_range(template)
    template.safe_join(
      [
        I18n.l(game_started_at, format: :hours_minutes_seconds),
        I18n.l(game_ended_at, format: :hours_minutes_seconds),
      ],
      "&ndash;".html_safe)
  end

  def stats
    Games::Stats.new(game:)
  end

  def duty_roster
    Games::Users::DutyRoster.new(game:)
  end

  private

  attr_reader :game,
              :user

  def game_started_at = game.started_at
  def game_ended_at = game.ended_at
end
