# frozen_string_literal: true

# Games::Past::ElapsedTime is a view wrapper around {::ElapsedTime}, for
# displaying elapsed time details for just-ended/past {Game}s.
class Games::Past::ElapsedTime
  def initialize(game:)
    @game = game
  end

  # "Total Seconds"
  def to_i
    @to_i ||= elapsed_time.to_i
  end

  def to_s
    I18n.l(time, format: :minutes_seconds)
  end

  def time_range(separator: "–")
    View.safe_join([
      I18n.l(started_at, format: :hours_minutes_seconds),
      I18n.l(ended_at, format: :hours_minutes_seconds),
    ], separator)
  end

  def game_ended_at = ended_at

  private

  attr_reader :game

  def started_at = game.started_at
  def ended_at = game.ended_at

  def elapsed_time
    @elapsed_time ||= ::ElapsedTime.new(ended_at..)
  end

  def time
    @time ||= elapsed_time.to_time
  end
end
