# frozen_string_literal: true

# Games::Past::PerformanceMetrics::Efficiency provides accessors for
# the "Efficiency" performance metric.
class Games::Past::PerformanceMetrics::Efficiency
  include Games::Past::PerformanceMetrics::Behaviors

  def query_method = :efficiency?
end
