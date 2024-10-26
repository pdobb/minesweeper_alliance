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
