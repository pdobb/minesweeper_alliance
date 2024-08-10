class Board < ApplicationRecord
  DEFAULTS = {
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

  def grid
    cells.group_by(&:y).values
  end

  private

  def inspect_identification
    identify(:columns, :rows, :mines)
  end

  def inspect_info
    "#{cells.size} Cells"
  end

  # [
  #   [<Cell(💣) 0, 0>, <Cell(💣) 1, 0>, <Cell(◻️) 2, 0>],
  #   [<Cell(◻️) 0, 1>, <Cell(💣) 1, 1>, <Cell(◻️) 2, 1>],
  #   [<Cell(◻️) 0, 2>, <Cell(💣) 1, 2>, <Cell(◻️) 2, 2>]
  # ]
  def generate
    Array.new(rows) { |y|
      Array.new(columns) { |x|
        cells.build(x:, y:)
      }
    }
  end
end
