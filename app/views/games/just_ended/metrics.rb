# frozen_string_literal: true

# Games::Past::Metrics is a specialized version of {Games::Past::Metrics} that
# represents end-of-{Game} scores/stats for just-ended {Game}s.
class Games::JustEnded::Metrics < Games::Past::Metrics
  def cacheable? = false

  def performance_metrics(user:)
    Games::JustEnded::PerformanceMetrics.new(user:, game:)
  end
end
