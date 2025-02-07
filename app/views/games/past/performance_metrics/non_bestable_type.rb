# frozen_string_literal: true

# Games::Past::PerformanceMetrics::NonBestableType is a generic Metric type,
# used when {Game#bestable_type?} == false. It simply passes through {#value}
# while denying any "bests".
class Games::Past::PerformanceMetrics::NonBestableType
  def initialize(value:)
    @value = value
  end

  def container_css = nil
  def best? = false

  def to_s = value.to_s

  private

  attr_reader :value
end
