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

  # Board::Error represents any StandardError related to Board processing.
  Error = Class.new(StandardError)

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

  validate :validate_settings, on: :create

  def settings
    @settings ||= Settings.new(**super)
  end

  def settings=(value)
    super(value.to_h)
  end

  def width = settings.width
  def height = settings.height
  def mines = settings.mines
  def dimensions = "#{settings.width}x#{settings.height}"

  def place_mines(seed_cell: nil)
    RandomlyPlaceMines.(board: self, seed_cell:)

    self
  end

  def check_for_victory
    return unless game.status_sweep_in_progress?

    all_safe_cells_have_been_revealed? and game.end_in_victory
  end

  def cells_at(coordinates)
    coordinates = Array.wrap(coordinates)
    cells.select { |cell| cell.coordinates.in?(coordinates) }
  end

  def mines_placed? = cells.any?(&:mine?)
  def flags_count = cells.count(&:flagged?)

  def grid(context: nil)
    Grid.new(cells, context:)
  end

  private

  def all_safe_cells_have_been_revealed?
    cells.none?(&:safely_revealable?)
  end

  def validate_settings
    return if settings.valid?

    errors.merge!(settings.errors)
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
      raise(Error, "mines have already been placed") if mines_placed?

      updated_cells = place_mines_in_random_cells
      save_mines_placement(updated_cells)
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

  # Board::Console acts like a {Board} but otherwise handles IRB
  # Console-specific methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def grid = super.console

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
        "#{Icon.mine} #{mines}",
        "#{Icon.flag} #{flags_count}",
      ])
    end

    def cells_count = cells.size

    def revealed_cells_count
      cells.count(&:revealed?)
    end
  end
end
