# frozen_string_literal: true

# Games::Past::PerformanceMetrics represents performance-related end-of-{Game}
# metrics/stats for past {Game}s.
class Games::Past::PerformanceMetrics
  def initialize(game:)
    @game = game
  end

  def score
    return Game::MAX_SCORE if score_value >= Game::MAX_SCORE

    View.display(score_value) { |value| View.round(value) }
  end

  def bbbv = bbbv_value || View.no_value_indicator

  def bbbvps
    View.display(bbbvps_value) { |value| View.round(value) }
  end

  def efficiency
    View.display(efficiency_value) { |value| View.percentage(value * 100.0) }
  end

  private

  attr_reader :game

  def score_value = game.score
  def bbbv_value = game.bbbv
  def bbbvps_value = game.bbbvps
  def efficiency_value = game.efficiency
end
