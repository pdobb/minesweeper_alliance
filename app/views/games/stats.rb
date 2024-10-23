# frozen_string_literal: true

# Games::Stats is a View Model for displaying end-of-{Game} stats.
#
# @see Games::Results
class Games::Stats
  DEFAULT_PRECISION = 2

  def initialize(game:)
    @game = game
  end

  def cache_name = [game, :stats]

  def show_game_score? = game.ended_in_victory?

  def display_game_score
    game_score.round(DEFAULT_PRECISION)
  end

  def display_3bv = bbbv

  def display_3bvps
    (bbbv / game_score.to_f).round(DEFAULT_PRECISION)
  end

  def display_efficiency_percentage
    percentage(efficiency_percent * 100.0)
  end

  def display_clicks_count
    delimit(clicks_count)
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

  def board = game.board
  def grid = board.grid

  def game_score = game.score

  def bbbv
    @bbbv ||= Calc3BV.(grid)
  end

  def efficiency_percent
    bbbv / clicks_count.to_f
  end

  def clicks_count
    game.cell_transactions.size
  end

  def percentage(value, precision: DEFAULT_PRECISION)
    helpers.number_to_percentage(value, precision:)
  end

  def delimit(value)
    helpers.number_with_delimiter(value)
  end

  def helpers = ActionController::Base.helpers
end
