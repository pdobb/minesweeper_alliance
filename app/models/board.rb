# frozen_string_literal: true

class Board < ApplicationRecord
  Error = Class.new(StandardError)

  DEFAULTS = {
    test: { columns: 3, rows: 3, mines: 3 },
    beginner: { columns: 9, rows: 9, mines: 10 },
    intermediate: { columns: 16, rows: 16, mines: 40 },
    expert: { columns: 24, rows: 24, mines: 99 },
    web: { columns: 30, rows: 16, mines: 99 },
  }

  after_update_commit  -> { broadcast_refresh }

  belongs_to :game
  has_many :cells

  def self.build_for(game, difficulty_level:)
    defaults_for_given_difficulty_level =
      DEFAULTS.fetch(difficulty_level.to_sym)

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

  def any_mines? = cells.is_a_mine.any?

  def cells_count = cells.size
  def mines_count = cells.is_a_mine.size
  def revealed_cells_count = cells.is_revealed.size
  def flags_count = cells.is_flagged.size

  def display_grid_size = "#{columns} x #{rows}"

  def cells_grid
    Grid.new(cells.by_coordinates_asc)
  end

  def render
    puts self.inspect
    cells_grid.render
  end

  def clamp_coordinates(coordinates_array)
    coordinates_array.select(&method(:in_bounds?))
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

  def generate
    Array.new(rows) { |y|
      Array.new(columns) { |x|
        build_cell(x:, y:)
      }
    }
  end

  def build_cell(x:, y:)
    cells.build(coordinates: Coordinates[x, y])
  end

  def columns_range
    0..columns
  end

  def rows_range
    0..rows
  end
end
