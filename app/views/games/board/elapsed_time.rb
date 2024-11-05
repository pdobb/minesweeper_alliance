# frozen_string_literal: true

# Games::Board::ElapsedTime is a view wrapper around {::ElapsedTime}, for
# displaying elapsed time details for current/just-ended/past {Game}s.
class Games::Board::ElapsedTime
  MAX_TIME_STRING = "23:59:59+"

  attr_reader :elapsed_time

  def initialize(time_range)
    @elapsed_time = ::ElapsedTime.new(time_range)
  end

  # "Total Seconds"
  def to_i
    @to_i ||= elapsed_time.to_i
  end

  def to_s
    if over_a_day?
      MAX_TIME_STRING
    else
      I18n.l(time, format: determine_format)
    end
  end

  private

  def time
    @time ||= elapsed_time.to_time
  end

  def over_a_day? = elapsed_time.over_a_day?

  def determine_format
    if time.hour.positive?
      :hours_minutes_seconds
    elsif time.min.positive?
      :minutes_seconds
    else
      :seconds
    end
  end
end
