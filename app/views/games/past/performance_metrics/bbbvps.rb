# frozen_string_literal: true

# Games::Past::PerformanceMetrics::BBBVPS provides accessors for the
# "3BV/s" performance metric.
class Games::Past::PerformanceMetrics::BBBVPS
  include Games::Past::PerformanceMetrics::Behaviors

  def query_method = :bbbvps?
end
