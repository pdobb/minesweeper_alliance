# frozen_string_literal: true

# Games::Stats is a View Model for displaying end-of-{Game} stats.
#
# @see Games::Results
class Games::Stats
  PRECISION = 3

  def initialize(game:)
    @game = game
  end

  def cache_name = [game, :stats]

  def show_game_score? = game.ended_in_victory?
  def game_score = game.score

  def bbbv
    @bbbv ||= Calc3BV.(grid)
  end

  def bbbv_per_second
    (bbbv / game_score.to_f).round(PRECISION)
  end

  def reveals_count
    game.cell_reveal_transactions.size
  end

  def flags_count
    game.cell_flag_transactions.size
  end

  def unflags_count
    game.cell_unflag_transactions.size
  end

  private

  attr_reader :game

  def board = game.board
  def grid = board.grid
end
