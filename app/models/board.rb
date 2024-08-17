# frozen_string_literal: true

# Board represents a collection of {Cell}s. Internally, these {Cell}s are
# organized as just one big Array, but they can best be though of as an Array of
# Arrays, forming an X/Y grid.
#
# @see Grid
class Board < ApplicationRecord
  # Board::Error represents any StandardError related to Board processing.
  Error = Class.new(StandardError)

  DIFFICULTY_LEVELS_MAP = {
    test: { columns: 3, rows: 3, mines: 3 },
    beginner: { columns: 9, rows: 9, mines: 10 },
    intermediate: { columns: 16, rows: 16, mines: 40 },
    expert: { columns: 30, rows: 16, mines: 99 },
  }.freeze

  after_update_commit -> { broadcast_refresh }

  belongs_to :game
  has_many :cells

  def self.build_for(game, difficulty_level:)
    defaults_for_given_difficulty_level =
      DIFFICULTY_LEVELS_MAP.fetch(difficulty_level.to_sym)

    build_for_custom(game, **defaults_for_given_difficulty_level)
  end

  def self.build_for_custom(game, columns:, rows:, mines:)
    game.build_board(columns:, rows:, mines:).tap { |new_board|
      new_board.__send__(:generate)
    }
  end

  def place_mines
    raise(Error, "mines have already been placed") if any_mines?

    cells.limit(mines).by_random.update_all(mine: true)

    self
  end

  def reveal_random_cell
    cells.by_random.is_not_revealed.take.reveal
  end

  def check_for_victory
    game.end_in_victory if all_safe_cells_have_been_revealed?
    self
  end

  def end_game_in_defeat
    game.end_in_defeat
    self
  end

  def all_safe_cells_have_been_revealed?
    cells.is_not_a_mine.is_not_revealed.none?
  end

  def any_mines? = cells.is_a_mine.any?

  def cells_count = cells.size
  def mines_count = cells.is_a_mine.size
  def revealed_cells_count = cells.is_revealed.size
  def flags_count = cells.is_flagged.size

  def display_grid_size = "#{columns} x #{rows}"

  def cells_grid
    Grid.new(cells.by_least_recent)
  end

  def render
    puts inspect # rubocop:disable Rails/Output
    cells_grid.render
  end

  def clamp_coordinates(coordinates_array)
    # rubocop:todo Performance/MethodObjectAsBlock
    coordinates_array.select(&method(:in_bounds?))
    # rubocop:enable Performance/MethodObjectAsBlock
  end

  def in_bounds?(coordinates)
    columns_range.include?(coordinates.x) && rows_range.include?(coordinates.y)
  end

  private

  def inspect_identification
    identify
  end

  def inspect_info(scope:)
    scope.join_info([
      "#{display_grid_size} Grid",
      "#{Cell::CELL_ICON} #{cells_count}",
      "#{Cell::MINE_ICON} #{mines_count}",
      "#{Cell::REVEALED_CELL_ICON} #{revealed_cells_count}",
      "#{Cell::FLAG_ICON} #{flags_count}",
    ])
  end

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
end
