# frozen_string_literal: true

# Board::RandomlyPlaceMines is a Service Object that handles placing mines in
# {Cell}s at random.
class Board::RandomlyPlaceMines
  include CallMethodBehaviors

  attr_reader :board,
              :seed_cell

  def initialize(board:, seed_cell:)
    @board = board
    @seed_cell = seed_cell
  end

  def on_call
    raise(Board::Error, "can't place mines in an unsaved Board") if new_record?
    raise(Board::Error, "mines have already been placed") if mines_placed?

    updated_cells = place_mines_in_random_cells
    save_mines_placement(updated_cells)

    self
  end

  private

  def new_record? = board.new_record?
  def cells = @cells ||= board.cells
  def mines_placed? = board.mines_placed?
  def mines = board.mines

  def place_mines_in_random_cells
    eligible_cells.sample(mines).each(&:place_mine)
  end

  def eligible_cells
    cells.to_a.excluding(seed_cell)
  end

  def save_mines_placement(mine_cells)
    Cell.for_id(mine_cells).update_all(mine: true)
  end
end
