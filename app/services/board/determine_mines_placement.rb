# frozen_string_literal: true

# Board::DetermineMinesPlacement handles the decision on what mines placement
# strategy to employ and then enacts it.
class Board::DetermineMinesPlacement
  def self.call(...) = new(...).call

  def initialize(board:, seed_cell:)
    @board = board
    @seed_cell = seed_cell
  end

  def call
    if pattern?
      Board::PlaceMines.(board:, coordinates_array:, seed_cell:)
    else
      Board::RandomlyPlaceMines.(board:, seed_cell:)
    end
  end

  private

  attr_reader :board,
              :seed_cell

  def pattern? = board.pattern?
  def pattern = board.pattern
  def coordinates_array = pattern.coordinates_array
end
