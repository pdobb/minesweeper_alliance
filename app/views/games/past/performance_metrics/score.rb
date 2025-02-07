# frozen_string_literal: true

# Games::Past::PerformanceMetrics::Score provides accessors for the
# "Score" performance metric.
class Games::Past::PerformanceMetrics::Score
  include Games::Past::PerformanceMetrics::Behaviors

  def query_method = :score?
end
