# frozen_string_literal: true

# Board::Generate is a Service Object that handles insertion of {Cell} records
# for this Board into the Database via bulk insert.
class Board::Generate
  # Board::Generate::Error represents any StandardError related to Board
  # generation.
  Error = Class.new(StandardError)

  ONE_MICROSECOND = 0.00001r

  include CallMethodBehaviors

  def initialize(board:)
    raise(Error, "board can't be a new record") unless board.persisted?

    @board = board
  end

  def on_call
    Cell.insert_all!(cell_data)
  end

  private

  attr_reader :board

  def cell_data
    (0...total).map { |index|
      build_for(index)
    }
  end

  def build_for(index)
    coordinates = build_coordinates_for(index)
    created_at = updated_at = build_timestamp_for(index)

    { board_id: board.id, coordinates:, created_at:, updated_at: }
  end

  def build_coordinates_for(index)
    x = index % width
    y = index / width
    Coordinates[x, y]
  end

  # Ensure Cells are properly sortable by {Cell#created_at}.
  def build_timestamp_for(index)
    now + (index * ONE_MICROSECOND)
  end

  def now = @now ||= Time.current
  def total = width * height
  def width = board.width
  def height = board.height
end
