# frozen_string_literal: true

# Games::Past::Board::Footer represents the {Board} footer for current
# {Game}s.
class Games::Past::Board::Footer
  def initialize(board:)
    @board = board
  end

  def game_type
    [
      (pattern_name.inspect if pattern?),
      game.type,
    ].tap(&:compact!).join(" ")
  end

  def dimensions = board.dimensions

  private

  attr_reader :board

  def game = board.game
  def pattern? = board.pattern?
  def pattern_name = board.pattern_name
end
