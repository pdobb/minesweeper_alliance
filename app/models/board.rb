# frozen_string_literal: true

# :reek:TooManyMethods
# :reek:RepeatedConditional

# Board represents a collection of {Cell}s. Internally, these {Cell}s are
# organized as just one big Array, but they can best be visualized as an Array
# of Arrays--forming an X/Y grid. Indeed, we must represent the {Cell}s as a
# grid in the UI at some point... and it is {Grid#to_h} that accomplishes this.
# This grid of {Cell}s is never persisted, but, rather, is just always created
# on demand / as needed.
#
# @attr settings [Hash] An object that stores the width, height,
#   and number of mines (to be set) in the {Grid} of associated {Cell}s.
#   Converted to {Board::Settings} via {#settings} getter override.
#
# @see Grid
class Board < ApplicationRecord
  self.implicit_order_column = "created_at"

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

  def generate_cells
    Generate.(board: self)
  end

  def place_mines(seed_cell:)
    if pattern?
      coordinates_array = pattern.coordinates_array
      PlaceMines.(board: self, coordinates_array:, seed_cell:)
    else
      RandomlyPlaceMines.(board: self, seed_cell:)
    end
  end

  def settings
    @settings ||= Settings.new(**super)
  end

  def settings=(value)
    super(value.to_h)
  end

  def width = settings.width
  def height = settings.height
  def mines = settings.mines
  def dimensions = "#{width}x#{height}"
  def pattern? = settings.pattern?

  def pattern
    @pattern ||= Pattern.find_by!(name: pattern_name)
  end

  def pattern_name
    settings.name if pattern?
  end

  def check_for_victory(user:)
    return unless game.status_sweep_in_progress?

    all_safe_cells_have_been_revealed? and Game::EndInVictory.(game:, user:)
  end

  def cells_at(coordinates_array)
    coordinates_array = Array.wrap(coordinates_array)
    cells.select { |cell| coordinates_array.include?(cell.coordinates) }
  end

  def mine_cells = cells.select(&:mine?)

  def mines_placed? = cells.any?(&:mine?)
  def flags_count = cells.count(&:flagged?)

  def grid
    Grid.new(cells)
  end

  private

  def all_safe_cells_have_been_revealed?
    cells.none? { Cell::State.safely_revealable?(it) }
  end

  def validate_settings
    return if settings.valid?

    errors.merge!(settings.errors)
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      { self => grid.introspect }
    end

    private

    def inspect_identification = identify(:id, :game_id)

    def inspect_info(scope:)
      scope.join_info([
        "#{Emoji.cell} x#{cells_count} (#{dimensions})",
        "#{Emoji.revealed_cell} #{revealed_cells_count}",
        "#{Emoji.mine} #{mines}",
        "#{Emoji.flag} #{flags_count}",
      ])
    end

    def cells_count = cells.size
    def revealed_cells_count = cells.count(&:revealed?)
  end

  # Board::Console acts like a {Board} but otherwise handles IRB
  # Console-specific methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def grid = super.console

    def render
      puts(inspect)
      grid.render
    end

    def reset
      __model__.cells.update_all(
        revealed: false,
        flagged: false,
        highlight_origin: false,
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
        highlight_origin: false,
        highlighted: false,
        value: nil)

      self
    end
  end
end
