# frozen_string_literal: true

# Board represents a collection of {Cell}s. Internally, these {Cell}s are
# organized as just one big Array, but they can best be though of as an Array of
# Arrays, forming an X/Y grid.
#
# @see Grid
class Board < ApplicationRecord
  # Board::Error represents any StandardError related to Board processing.
  Error = Class.new(StandardError)

  after_update_commit -> { broadcast_refresh }

  belongs_to :game
  has_many :cells, dependent: :delete_all

  # @@attr difficulty_level [DifficultyLevel]
  def self.build_for(game:, difficulty_level:)
    build_for_custom(game:, difficulty_level:)
  end

  # @@attr difficulty_level [DifficultyLevel]
  def self.build_for_custom(game:, difficulty_level:)
    game.
      build_board(
        columns: difficulty_level.columns,
        rows: difficulty_level.rows,
        mines: difficulty_level.mines).
      tap { |new_board| new_board.__send__(:generate) }
  end

  def place_mines(seed_cell:)
    raise(Error, "mines have already been placed") if any_mines?

    cells.not_for_id(seed_cell).by_random.limit(mines).update_all(mine: true)

    self
  end

  def reset
    cells.update_all(
      revealed: false,
      flagged: false,
      highlighted: false,
      value: nil)
  end

  def reveal_random_cell
    cells.for_id(random_cell_id_for_reveal).take.reveal
  end

  def check_for_victory
    return if game.over?

    game.end_in_victory if all_safe_cells_have_been_revealed?
    self
  end

  def all_safe_cells_have_been_revealed?
    cells.is_not_mine.is_not_revealed.none?
  end

  def any_mines? = cells.is_mine.any?

  def cells_count = cells.size
  def mines_count = cells.is_mine.size
  def revealed_cells_count = cells.is_revealed.size
  def flags_count = cells.is_flagged.size

  def cells_grid
    Grid.new(cells.by_least_recent)
  end

  def render
    puts inspect # rubocop:disable Rails/Output
    cells_grid.render
  end

  def clamp_coordinates(coordinates_array)
    coordinates_array.select { |coordinates| in_bounds?(coordinates) }
  end

  def in_bounds?(coordinates)
    columns_range.include?(coordinates.x) && rows_range.include?(coordinates.y)
  end

  private

  def inspect_identification = identify

  def inspect_info(scope:)
    scope.join_info([
      "#{Icon.cell} #{cells_count} (#{display_grid_size})",
      "#{Icon.revealed_cell} #{revealed_cells_count}",
      "#{Icon.mine} #{mines_count}",
      "#{Icon.flag} #{flags_count}",
    ])
  end

  def display_grid_size = "#{columns}x#{rows}"

  # :reek:UncommunicativeVariableName
  def generate
    Array.new(rows) { |y| generate_row(y) }
  end

  # :reek:UncommunicativeParameterName
  # :reek:UncommunicativeVariableName
  def generate_row(y) # rubocop:disable Naming/MethodParameterName
    Array.new(columns) { |x| build_cell(x:, y:) }
  end

  # :reek:UncommunicativeParameterName
  def build_cell(x:, y:) # rubocop:disable Naming/MethodParameterName
    cells.build(coordinates: Coordinates[x, y])
  end

  def columns_range
    0..columns
  end

  def rows_range
    0..rows
  end

  def random_cell_id_for_reveal
    cells.is_not_revealed.is_not_flagged.by_random.pick(:id)
  end
end
