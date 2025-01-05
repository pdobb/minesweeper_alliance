# frozen_string_literal: true

# Games::Past::Board::Content represents the actual {Board} content for past
# {Game}s.
class Games::Past::Board::Content
  def initialize(board:)
    @board = board
  end

  def just_ended_game? = game.just_ended?

  def rows
    grid.map { |row| Games::Past::Board::Cell.wrap(row, game:) }
  end

  private

  attr_reader :board

  def game = board.game
  def grid = board.grid
end
