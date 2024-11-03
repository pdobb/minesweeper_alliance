# frozen_string_literal: true

# Games::Metrics is a View Model for displaying end-of-{Game} scores/stats.
#
# @see Games::Results
class Games::Metrics
  def initialize(game:)
    @game = game
  end

  def cache_key = [game, :metrics]

  def show_game_score? = game.ended_in_victory?

  def game_score
    View.display(_score) { |value| View.round(value) }
  end

  def bbbv = _bbbv || View.no_value_indicator

  def bbbvps
    View.display(_bbbvps) { |value| View.round(value) }
  end

  def efficiency_percentage
    View.display(_efficiency) { |value| View.percentage(value * 100.0) }
  end

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

  def _score = game.score
  def _bbbv = game.bbbv
  def _bbbvps = game.bbbvps
  def _efficiency = game.efficiency
end
