# frozen_string_literal: true

# Games::Past::PerformanceMetrics represents performance-related end-of-{Game}
# metrics/stats for just-ended/past {Game}s.
#
# This class adds either an "Alliance Best" or a "Personal Best" (but never both
# at the same time) indicators to each of the tracked metrics, where applicable:
# - Score,
# - 3BV/s, and
# - Efficiency.
#
# Note: We're able to render *Personal* Bests even for just-ended {Game}s
# because, there, we're using a lazy-loaded Turbo frame to render
# `games/just_ended/<active_participants|observer>/footer` for each participant
# ({User}).
class Games::Past::PerformanceMetrics
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def score = build_type(Score, value: score_value)
  def bbbv = game_bbbv
  def bbbvps = build_type(Bbbvps, value: bbbvps_value)
  def efficiency = build_type(Efficiency, value: efficiency_value)

  private

  attr_reader :game,
              :user

  def build_type(type, value:)
    if bestable?
      type.new(game:, user:, value:)
    else
      NonBestableType.new(value:)
    end
  end

  # :reek:NilCheck
  def bestable?
    if @bestable.nil?
      @bestable = game.bestable_type?
    else
      @bestable
    end
  end

  def score_value
    return Game::MAX_SCORE if game_score >= Game::MAX_SCORE

    View.display(game_score) { |value| View.round(value) }
  end

  def bbbvps_value
    View.display(game_bbbvps) { |value| View.round(value) }
  end

  def efficiency_value
    View.display(game_efficiency) { |value| View.percentage(value * 100.0) }
  end

  def game_score = game.score
  def game_bbbv = game.bbbv
  def game_bbbvps = game.bbbvps
  def game_efficiency = game.efficiency
end
