# frozen_string_literal: true

# Games::Past::PerformanceMetrics::Bbbvps provides accessors for the
# "3BV/s" performance metric.
class Games::Past::PerformanceMetrics::Bbbvps
  include Games::Past::PerformanceMetrics::Behaviors

  def query_method = :bbbvps?
end
