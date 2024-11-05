# frozen_string_literal: true

# Games::Board::Footer represents the {Board} footer for current/just-ended/past
# {Game}s.
class Games::Board::Footer
  def initialize(board:)
    @board = board
  end

  def game_type = game.type
  def dimensions = board.dimensions

  private

  attr_reader :board

  def game = board.game
end
