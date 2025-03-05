# frozen_string_literal: true

# Games::JustEnded::ElapsedTime is a view wrapper around {::ElapsedTime}, for
# displaying elapsed time details for just-ended {Game}s.
class Games::JustEnded::ElapsedTime
  def initialize(ended_at:)
    @ended_at = ended_at
  end

  def started_at = ended_at

  # "Total Seconds"
  def to_i
    @to_i ||= elapsed_time.to_i
  end

  def to_s
    I18n.l(time, format: :minutes_seconds)
  end

  private

  attr_reader :ended_at

  def elapsed_time
    @elapsed_time ||= ::ElapsedTime.new(ended_at..)
  end

  def time
    @time ||= elapsed_time.to_time
  end
end
