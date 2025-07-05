# frozen_string_literal: true

# Game::Stats::Calculate determines and updates the given {Game} object with
# relevant statistical values (on {Game} end).
class Game::Stats::Calculate
  def self.call(...) = new(...).call

  def initialize(game)
    @game = game
  end

  def call
    game.update(
      score:,
      bbbv:,
      bbbvps:,
      efficiency:,
    )
  end

  private

  attr_reader :game

  def score
    [duration, Game::MAX_SCORE].min
  end

  def duration = Game::Stats.duration(game)

  def bbbv
    @bbbv ||= Board::Calc3BV.(grid)
  end

  def grid = game.board.grid

  def bbbvps
    bbbv / score.to_f
  end

  def efficiency
    bbbv / clicks_count.to_f
  end

  def clicks_count = game.cell_transactions.size
end
