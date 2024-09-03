# frozen_string_literal: true

# ElapsedTime is a utility class for building a Time object that represents the
# number of hours/minutes/seconds that have elapsed between a given start and
# end time.
#
# NOTE: We return a Ruby Time object for convenience, but since we can't divorce
# dates from Time values in Ruby, a static year, month, and day value must be
# returned as well. They should be ignored.
class ElapsedTime
  SECONDS_PER_DAY = 1.day.to_i

  attr_reader :start_time,
              :end_time

  def initialize(between = nil..)
    now = Time.current
    @start_time = between.begin || now
    @end_time = between.end || now
  end

  # @return [ElapsedTime::Timestamp]
  def to_time
    Time.zone.local(*time_params)
  end

  # @return [Integer] The total number of elapsed seconds.
  def to_i
    @to_i ||= (end_time - start_time).to_i
  end

  def over_one_day?
    to_i > SECONDS_PER_DAY
  end

  private

  def time_params
    if over_one_day?
      [2024, 1, 1, 23, 59, 59]
    else
      [2024, 1, 1, *Parse.(to_i)]
    end
  end

  # ElapsedTime::Parse parses out the passed-in total seconds into an hours,
  # minutes, and seconds Array.
  class Parse
    SECONDS_PER_HOUR = 1.hour.to_i
    SECONDS_PER_MINUTE = 1.minute.to_i

    include CallMethodBehaviors

    attr_reader :total_seconds

    def initialize(total_seconds)
      @total_seconds = total_seconds
    end

    # @return [Array] e.g. [<hours>, <minutes>, <seconds>]
    def on_call
      remaining_seconds = total_seconds.dup
      hours, remaining_seconds = parse_hours(remaining_seconds)

      [
        hours,
        parse_minutes(remaining_seconds),
        parse_seconds(remaining_seconds),
      ]
    end

    private

    def parse_hours(remaining_seconds)
      hours = (remaining_seconds / SECONDS_PER_HOUR).floor
      remaining_seconds %= SECONDS_PER_HOUR
      [hours, remaining_seconds]
    end

    def parse_minutes(remaining_seconds)
      (remaining_seconds / SECONDS_PER_MINUTE).floor
    end

    def parse_seconds(remaining_seconds)
      remaining_seconds % SECONDS_PER_MINUTE
    end
  end
end
