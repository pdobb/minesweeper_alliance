# frozen_string_literal: true

# Games::Past::Board::Content represents the actual {Board} content for past
# {Game}s.
class Games::Past::Board::Content
  def initialize(board:)
    @board = board
  end

  def grid_context(context)
    @grid_context ||= Games::Board::GridContext.new(context:, board:)
  end

  def rows(context:)
    grid(context:).map { |row| Games::Past::Board::Cell.wrap(row, game:) }
  end

  private

  attr_reader :board

  def game = board.game

  def grid(context:)
    @grid ||= board.grid(context:)
  end
end
