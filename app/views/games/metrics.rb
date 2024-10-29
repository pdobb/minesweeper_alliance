# frozen_string_literal: true

# Games::Metrics is a View Model for displaying end-of-{Game} scores/stats.
#
# @see Games::Results
class Games::Metrics
  DEFAULT_PRECISION = 2
  NO_VALUE_INDICATOR = "—"

  def initialize(game:)
    @game = game
  end

  def cache_key = [game, :metrics]

  def show_game_score? = game.ended_in_victory?

  def game_score
    _score ? _score.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def bbbv = _bbbv || NO_VALUE_INDICATOR

  def bbbvps
    _bbbvps ? _bbbvps.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def efficiency_percentage
    _efficiency ? percentage(_efficiency * 100.0) : NO_VALUE_INDICATOR
  end

  def clicks_count
    delimit(game.cell_transactions.size)
  end

  def reveals_count
    delimit(game.cell_reveal_transactions.size)
  end

  def chords_count
    delimit(game.cell_chord_transactions.size)
  end

  def flags_count
    delimit(game.cell_flag_transactions.size)
  end

  def unflags_count
    delimit(game.cell_unflag_transactions.size)
  end

  private

  attr_reader :game

  def _score = game.score
  def _bbbv = game.bbbv
  def _bbbvps = game.bbbvps
  def _efficiency = game.efficiency

  def percentage(value, precision: DEFAULT_PRECISION)
    helpers.number_to_percentage(value, precision:)
  end

  def delimit(value)
    helpers.number_with_delimiter(value)
  end

  def helpers = ActionController::Base.helpers
end
