# frozen_string_literal: true

# :reek:TooManyMethods

# Board represents a collection of {Cell}s. Internally, these {Cell}s are
# organized as just one big Array, but they can best be though of as an Array of
# Arrays, forming an X/Y {Grid}.
#
# @attr settings [Hash] An object that stores the width, height,
#   and number of mines (to be) in the {Grid} of associated {Cell}s.
#   Converted to {Board::Settings} via {#settings} getter override.
#
# @see Grid
class Board < ApplicationRecord
  self.implicit_order_column = "created_at"

  VALID_SETTINGS_VALUES_RANGES = {
    width: VALID_WIDTH_VALUES_RANGE = 3..30,
    height: VALID_HEIGHT_VALUES_RANGE = 3..30,
    mines: VALID_MINES_VALUES_RANGE = 1..225,
  }.freeze

  # Board::Error represents any StandardError related to Board processing.
  Error = Class.new(StandardError)

  # Board::Settings stores the width, height, and number of mines (to be) in
  # the {Grid} of a {Board}'s associated {Cell}s.
  Settings =
    Data.define(:width, :height, :mines) {
      def self.build_for(difficulty_level:)
        new(**difficulty_level.to_h)
      end

      def to_a = to_h.values
      def area = width * height
      def dimensions = "#{width}x#{height}"
    }

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

  validate :validate_settings

  def settings = @settings ||= Settings.new(**super)
  def width = settings.width
  def height = settings.height
  def mines = settings.mines
  def dimensions = settings.dimensions

  # @attr difficulty_level [DifficultyLevel]
  def self.build_for(game:, difficulty_level:)
    game.build_board(settings: Settings.build_for(difficulty_level:))
  end

  def place_mines(seed_cell: nil)
    RandomlyPlaceMines.(board: self, seed_cell:)

    self
  end

  def check_for_victory
    return self unless game.status_sweep_in_progress?

    game.end_in_victory if all_safe_cells_have_been_revealed?

    self
  end

  def cells_at(coordinates)
    coordinates = Array.wrap(coordinates)
    cells.select { |cell| cell.coordinates.in?(coordinates) }
  end

  def any_mines? = mines_count.positive?
  def mines_count = cells.count(&:mine?)
  def flags_count = cells.count(&:flagged?)

  def grid(context: nil)
    Grid.new(cells, context:)
  end

  private

  def all_safe_cells_have_been_revealed?
    cells.is_not_mine.is_not_revealed.none?
  end

  def validate_settings # rubocop:disable Metrics/MethodLength
    width, height, mines = settings.to_a

    if VALID_WIDTH_VALUES_RANGE.exclude?(width)
      errors.add(:settings, "width must be in #{VALID_WIDTH_VALUES_RANGE}")
    end
    if VALID_HEIGHT_VALUES_RANGE.exclude?(height)
      errors.add(:settings, "height must be in #{VALID_HEIGHT_VALUES_RANGE}")
    end
    if VALID_MINES_VALUES_RANGE.exclude?(mines)
      errors.add(:settings, "mines must be in #{VALID_MINES_VALUES_RANGE}")
    end

    errors.add(:settings, "can't be > total cells") if mines >= settings.area
  end

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

  # RandomlyPlaceMines is a Service Object that handles placing mines in
  # {Cell}s at random.
  class RandomlyPlaceMines
    include CallMethodBehaviors

    attr_reader :board,
                :seed_cell

    def initialize(board:, seed_cell:)
      @board = board
      @seed_cell = seed_cell
    end

    def on_call
      raise(Error, "mines can't be placed on an unsaved Board") if new_record?
      raise(Error, "mines have already been placed") if any_mines?

      updated_cells = place_mines_in_random_cells
      save_mines_placement(updated_cells)
    end

    private

    def new_record? = board.new_record?
    def cells = @cells ||= board.cells
    def any_mines? = board.any_mines?
    def mines = board.mines

    def place_mines_in_random_cells
      eligible_cells.shuffle!.take(mines).each(&:place_mine)
    end

    def eligible_cells
      cells.to_a.excluding(seed_cell)
    end

    def save_mines_placement(mine_cells)
      Cell.for_id(mine_cells).update_all(mine: true)
    end
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
        "#{Icon.cell} x#{cells_count} (#{dimensions})",
        "#{Icon.revealed_cell} #{revealed_cells_count}",
        "#{Icon.mine} #{mines_count}",
        "#{Icon.flag} #{flags_count}",
      ])
    end

    def cells_count = cells.size

    def random_cell_id_for_reveal
      cells.is_not_revealed.is_not_flagged.by_random.pick(:id)
    end

    def revealed_cells_count
      cells.try(:is_revealed)&.size || cells.size
    end
  end
end
