# frozen_string_literal: true

# Board represents a collection of {Cell}s. Internally, these {Cell}s are
# organized as just one big Array, but they can best be though of as an Array of
# Arrays, forming an X/Y {Grid}.
#
# @attr settings [Board::Settings] An object that stores the width, height, and
#   number of mines (to be) in the {Grid} of associated {Cell}s.
#
# @see Grid
class Board < ApplicationRecord
  self.implicit_order_column = "created_at"

  # Board::Error represents any StandardError related to Board processing.
  Error = Class.new(StandardError)

  # Board::Settings stores the width, height, and number of mines (to be) in
  # the {Grid} of a {Board}'s associated {Cell}s.
  Settings =
    Data.define(:width, :height, :mines) {
      def self.build_for(difficulty_level:)
        new(**difficulty_level.to_h)
      end
    }

  # Board::NullSettings represents an empty {Board::Settings}. It is an
  # implementation of the Null Object pattern, which allows us to use it as a
  # stand-in for any {Board} that doesn't yet have sensible
  # width/height/mines values.
  class NullSettings
    def width = nil
    def height = nil
    def mines = nil
    def to_h = {}
    def to_json(*) = "{}"
    def inspect = "<#{self.class.name}>"
    def to_s = inspect
  end

  include ConsoleBehaviors

  belongs_to :game

  has_many :cells,
           -> { by_least_recent },
           inverse_of: :board,
           dependent: :delete_all

  has_many :cell_transactions, through: :cells
  has_many :cell_reveal_transactions, through: :cells
  has_many :cell_flag_transactions, through: :cells
  has_many :cell_unflag_transactions, through: :cells

  scope :for_game, ->(game) { where(game:) }

  attribute :settings, Type::BoardSettings.new
  def width = settings.width
  def height = settings.height
  def mines = settings.mines

  # @attr difficulty_level [DifficultyLevel]
  def self.build_for(game:, difficulty_level:)
    game.build_board(settings: Settings.build_for(difficulty_level:))
  end

  def place_mines(seed_cell: nil)
    raise(Error, "mines can't be placed on an unsaved Board") if new_record?
    raise(Error, "mines have already been placed") if any_mines?

    cells.excluding(seed_cell).by_random.limit(mines).update_all(mine: true)

    self
  end

  def check_for_victory
    return self unless game.status_sweep_in_progress?

    game.end_in_victory if all_safe_cells_have_been_revealed?

    self
  end

  def mines_count = cells.is_mine.size
  def flags_count = cells.is_flagged.size

  def grid(context: nil)
    Grid.build_for(cells, context:)
  end

  def clamp_coordinates(coordinates_array)
    coordinates_array.select { |coordinates| in_bounds?(coordinates) }
  end

  private

  def all_safe_cells_have_been_revealed?
    cells.is_not_mine.is_not_revealed.none?
  end

  def any_mines? = cells.is_mine.any?

  def in_bounds?(coordinates)
    x_range.include?(coordinates.x) && y_range.include?(coordinates.y)
  end

  def x_range = 0...width
  def y_range = 0...height

  # Board::Generate is a Service Object that handles insertion of {Cell} records
  # for this Board into the Database via bulk insert.
  class Generate
    # Board::Generate::Error represents any StandardError related to Board
    # generation.
    Error = Class.new(StandardError)

    ONE_MICROSECOND = Rational("0.00001")

    include CallMethodBehaviors

    def initialize(board)
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

  # Board::Console acts like a {Board} but otherwise handles IRB
  # Console-specific methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def grid = super.console

    def reveal_random_cell
      cells.for_id(random_cell_id_for_reveal).take.reveal
    end

    def render
      puts inspect # rubocop:disable Rails/Output
      grid.render
    end

    def reset
      __model__.cells.update_all(
        revealed: false,
        flagged: false,
        highlighted: false,
        value: nil)

      self
    end

    # Like {#reset} but also resets mines.
    def reset!
      __model__.cells.update_all(
        revealed: false,
        mine: false,
        flagged: false,
        highlighted: false,
        value: nil)

      self
    end

    private

    def inspect_info(scope:)
      scope.join_info([
        "#{Icon.cell} x#{cells_count} (#{display_grid_dimensions})",
        "#{Icon.revealed_cell} #{revealed_cells_count}",
        "#{Icon.mine} #{mines_count}",
        "#{Icon.flag} #{flags_count}",
      ])
    end

    def cells_count = cells.size

    def display_grid_dimensions = "#{width}x#{height}"

    def random_cell_id_for_reveal
      cells.is_not_revealed.is_not_flagged.by_random.pick(:id)
    end

    def revealed_cells_count
      cells.try(:is_revealed)&.size || cells.size
    end
  end
end
