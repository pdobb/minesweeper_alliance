class Board < ApplicationRecord
  DEFAULTS = {
    test: { columns: 3, rows: 3, mines: 3 },
    beginner: { columns: 9, rows: 9, mines: 10 },
    intermediate: { columns: 16, rows: 16, mines: 40 },
    expert: { columns: 24, rows: 24, mines: 99 },
    web: { columns: 30, rows: 16, mines: 99 },
  }

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

  def cells_grid
    Grid.new(cells)
  end

  def clamp_coordinates(coordinates_array)
    coordinates_array.select { |coordinates|
      columns_range.cover?(coordinates.x) && rows_range.cover?(coordinates.y)
    }
  end

  private

  def inspect_identification
    identify(:columns, :rows, :mines)
  end

  def inspect_info
    "#{cells.size} Cells"
  end

  def generate
    Array.new(rows) { |y|
      Array.new(columns) { |x|
        cells.build(coordinates: Coordinates.new(x:, y:))
      }
    }
  end

  def columns_range
    0..columns
  end

  def rows_range
    0..rows
  end
end
