# frozen_string_literal: true

# Games::Past::PerformanceMetrics represents performance-related end-of-{Game}
# metrics/stats for past {Game}s.
class Games::Past::PerformanceMetrics
  ALLIANCE_BEST_CONTAINER_CSS = "text-yellow-400 dark:text-yellow-300"

  def initialize(game:)
    @game = game
  end

  def score = build_for(Score, value: score_value)
  def bbbvps = build_for(Bbbvps, value: bbbvps_value)
  def efficiency = build_for(Efficiency, value: efficiency_value)

  def score_value
    return Game::MAX_SCORE if _score_value >= Game::MAX_SCORE

    View.display(_score_value) { |value| View.round(value) }
  end

  def bbbv = _bbbv_value || View.no_value_indicator

  def bbbvps_value
    View.display(_bbbvps_value) { |value| View.round(value) }
  end

  def efficiency_value
    View.display(_efficiency_value) { |value| View.percentage(value * 100.0) }
  end

  private

  attr_reader :game

  def build_for(type, value:)
    if bestable?
      type.new(game_bests:, game:, value:)
    else
      NullPerformanceMetric.new(value:)
    end
  end

  # :reek:NilCheck
  def bestable?
    return @bestable unless @bestable.nil?

    @bestable = game.bestable_type?
  end

  def game_bests
    @game_bests ||= Game::Bests.for_type(game.type)
  end

  def _score_value = game.score
  def _bbbv_value = game.bbbv
  def _bbbvps_value = game.bbbvps
  def _efficiency_value = game.efficiency

  # :reek:ModuleInitialize

  # Games::Past::PerformanceMetrics::Behaviors ...
  module Behaviors
    attr_reader :value

    def initialize(game_bests:, game:, value:)
      @game_bests = game_bests
      @game = game
      @value = value
    end

    def alliance_best? = raise(NotImplementedError)

    def css
      ALLIANCE_BEST_CONTAINER_CSS if alliance_best?
    end

    private

    attr_reader :game_bests,
                :game
  end

  # Games::Past::PerformanceMetrics::Score provides accessors for the
  # "Score" performance metric.
  class Score
    include Behaviors

    def alliance_best? = game_bests.score?(game)
  end

  # Games::Past::PerformanceMetrics::Bbbvps provides accessors for the
  # "3BV/s" performance metric.
  class Bbbvps
    include Behaviors

    def alliance_best? = game_bests.bbbvps?(game)
  end

  # Games::Past::PerformanceMetrics::Efficiency provides accessors for
  # the "Efficiency" performance metric.
  class Efficiency
    include Behaviors

    def alliance_best? = game_bests.efficiency?(game)
  end

  # Games::Past::PerformanceMetrics::NullPerformanceMetric is a stand-in
  # for when {Game#bestable_type?} == false. It simply passes through {#value}
  # while denying any personal bests.
  class NullPerformanceMetric
    attr_reader :value

    def initialize(value:) = @value = value
    def alliance_best? = false
    def css = nil
  end
end
