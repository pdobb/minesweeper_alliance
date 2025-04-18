# frozen_string_literal: true

# Games::Past::Metrics represents end-of-{Game} scores/stats for past {Game}s.
class Games::Past::Metrics
  def initialize(game:)
    @game = game
  end

  def cacheable? = Game::Type.non_bestable?(game_type)
  def cache_key = [:past_game_container, game, :metrics]

  def show_performance_metrics? = Game::Status.ended_in_victory?(game)

  def performance_metrics(user:)
    Games::Past::PerformanceMetrics.new(game:, user:)
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

  def game_type = game.type
end
