# frozen_string_literal: true

# Games::Past::Metrics represents end-of-{Game} scores/stats for past {Game}s.
class Games::Past::Metrics
  def initialize(game:)
    @game = game
  end

  def cacheable? = true
  def cache_key = [game, :metrics]

  def show_performance_metrics? = game.ended_in_victory?

  def performance_metrics
    Games::Past::PerformanceMetrics.new(game:)
  end

  # Activity Metrics

  def clicks_count
    View.delimit(game.cell_transactions.size)
  end

  def reveals_count
    View.delimit(game.cell_reveal_transactions.size)
  end

  def chords_count
    View.delimit(game.cell_chord_transactions.size)
  end

  def flags_count
    View.delimit(game.cell_flag_transactions.size)
  end

  def unflags_count
    View.delimit(game.cell_unflag_transactions.size)
  end

  private

  attr_reader :game
end
