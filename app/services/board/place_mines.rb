# frozen_string_literal: true

# Board::PlaceMines is a Service Object that handles placing mines in {Cell}s at
# the given {Coordinates}.
class Board::PlaceMines
  # Board::PlaceMines::Error represents any StandardError related to
  # Board::PlaceMines processing.
  Error = Class.new(StandardError)

  def self.call(...) = new(...).call

  def initialize(board:, coordinates_set:, seed_cell:)
    @board = board
    @coordinates_set = coordinates_set
    @seed_cell = seed_cell
  end

  def call
    raise(Error, "can't place mines in an unsaved Board") if new_record?
    raise(Error, "mines have already been placed") if mines_placed?

    updated_cells = place_mines_in_cells
    save_mines_placement(updated_cells)

    self
  end

  private

  attr_reader :board,
              :coordinates_set,
              :seed_cell

  def new_record? = board.new_record?
  def cells = @cells ||= board.cells
  def mines_placed? = board.mines_placed?

  def place_mines_in_cells
    eligible_cells.each(&:place_mine)
  end

  def eligible_cells
    board.cells_at(coordinates_set).excluding(seed_cell)
  end

  def save_mines_placement(mine_cells)
    Cell.for_id(mine_cells).update_all(mine: true)
  end
end
