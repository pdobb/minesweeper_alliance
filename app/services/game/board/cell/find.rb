# frozen_string_literal: true

# Game::Board::Cell::Find finds the {Cell} with the given `cell_id` within the
# given {Board}. If not found, raises ActiveRecord::RecordNotFound.
class Game::Board::Cell::Find
  def self.call(...) = new(...).call

  def initialize(game:, cell_id:)
    @game = game
    @board = game.board
    @cell_id = cell_id.to_i
  end

  def call
    find_cell.tap { validate(it) }
  end

  private

  attr_reader :game,
              :board,
              :cell_id

  # NOTE: `bsearch` is O(log n), while `detect` is only O(n).
  def find_cell
    cells.bsearch { |cell| cell.id >= cell_id }
  end

  def cells = cells_arel.to_a

  def cells_arel
    arel = board.cells
    arel = arel.readonly if Game::Status.over?(game)
    arel
  end

  # :reek:ControlParameter

  # Since we're using bsearch, we must validate the result matches our
  # expectation. Because, e.g., For a `cell_id` < the lowest {Cell#id} in the
  # collection, bsearch returns the first Cell instead of `nil` (as we might
  # expect).
  def validate(cell)
    return if cell&.id == cell_id

    raise(
      ActiveRecord::RecordNotFound,
      "#{game.identify} -> #{board.identify} -> Cell[#{cell_id.inspect}]",
    )
  end
end
