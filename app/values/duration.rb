# frozen_string_literal: true

# Duration is a utility class for supplying a full breakout of the total time
# between a given start and end time.
class Duration
  UNITS_ORDER = %i[years months weeks days hours minutes seconds].freeze

  attr_reader :start_time,
              :end_time

  def initialize(between = nil.., duration_builder: ActiveSupport::Duration)
    now = Time.current
    @start_time = between.begin || now
    @end_time = between.end || now
    @duration_builder = duration_builder
  end

  def to_s
    return "#{duration_in_seconds}s" if less_than_a_minute?

    parts.
      map { |unit, value| "#{value}#{unit.to_s.first}" }.
      join(" ")
  end

  def to_i = duration.to_i

  # Return an hours/minutes/seconds-accurate representation of the duration,
  # since the beginning of the current day. Falls apart for durations >= 24
  # hours. Useful for `T+HH:MM:SS` designations.
  #
  # @return [Time]
  #
  # @example
  #   timestamp = Duration.new(94.seconds.ago..).to_plus_timestamp
  #   "T+#{timestamp.strftime("%H:%M:%S")}"
  #   # => "T+00:01:34"
  def to_plus_timestamp(since: Time.current.at_beginning_of_day)
    since + duration_in_seconds
  end

  private

  attr_reader :duration_builder

  def less_than_a_minute?
    parts.none?
  end

  def parts
    @parts ||= duration.parts.sort_by { |unit, _| UNITS_ORDER.index(unit) }
  end

  def duration
    @duration ||= duration_builder.build(duration_in_seconds)
  end

  def duration_in_seconds
    @duration_in_seconds ||= (end_time - start_time).to_i
  end
end
