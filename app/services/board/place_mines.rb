# frozen_string_literal: true

# Board::PlaceMines is a Service Object that handles placing mines in {Cell}s at
# the given {Coordinates}.
class Board::PlaceMines
  # Board::PlaceMines::Error represents any StandardError related to
  # Board::PlaceMines processing.
  Error = Class.new(StandardError)

  def self.call(...) = new(...).call

  def initialize(board:, coordinates_array:, seed_cell:)
    @board = board
    @coordinates_array = coordinates_array
    @seed_cell = seed_cell
  end

  def call
    raise(Error, "can't place mines in an unsaved Board") if new_record?
    raise(Error, "mines have already been placed") if mines_placed?

    updated_cells = place_mines
    save_mines_placement(updated_cells)

    self
  end

  private

  attr_reader :board,
              :coordinates_array,
              :seed_cell

  def new_record? = board.new_record?
  def cells = @cells ||= board.cells
  def mines_placed? = board.mines_placed?
  def mines = board.mines

  def place_mines
    eligible_cells.each(&:place_mine)
  end

  def eligible_cells
    board.cells_at(coordinates_array).excluding(seed_cell)
  end

  def save_mines_placement(mine_cells)
    Cell.for_id(mine_cells).update_all(mine: true)
  end
end
