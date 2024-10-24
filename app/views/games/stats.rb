# frozen_string_literal: true

# Games::Stats is a View Model for displaying end-of-{Game} stats.
#
# @see Games::Results
class Games::Stats
  DEFAULT_PRECISION = 2
  NO_VALUE_INDICATOR = "—"

  def initialize(game:)
    @game = game
  end

  def cache_name = [game, :stats]

  def show_game_score? = game.ended_in_victory?

  def display_game_score
    score ? score.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def display_bbbv = bbbv || NO_VALUE_INDICATOR

  def display_bbbvps
    bbbvps ? bbbvps.round(DEFAULT_PRECISION) : NO_VALUE_INDICATOR
  end

  def display_efficiency_percentage
    efficiency ? percentage(efficiency * 100.0) : NO_VALUE_INDICATOR
  end

  def display_clicks_count
    delimit(game.cell_transactions.size)
  end

  def display_reveals_count
    delimit(game.cell_reveal_transactions.size)
  end

  def display_chords_count
    delimit(game.cell_chord_transactions.size)
  end

  def display_flags_count
    delimit(game.cell_flag_transactions.size)
  end

  def display_unflags_count
    delimit(game.cell_unflag_transactions.size)
  end

  private

  attr_reader :game

  def score = game.score
  def bbbv = game.bbbv
  def bbbvps = game.bbbvps
  def efficiency = game.efficiency

  def percentage(value, precision: DEFAULT_PRECISION)
    helpers.number_to_percentage(value, precision:)
  end

  def delimit(value)
    helpers.number_with_delimiter(value)
  end

  def helpers = ActionController::Base.helpers
end
