# frozen_string_literal: true

# :reek:TooManyMethods

# Board represents a collection of {Cell}s. {Cell}s are stored in the database
# as a single dimensional Array, but logically represent an X/Y grid (an Array
# of Arrays). {Grid#to_h} handles this virtually (just-in-time).
#
# @attr settings [Hash] An object that stores the width, height,
#   and number of mines (to be set) in the {Grid} of associated {Cell}s.
#   Converted to {Board::Settings} via {#settings}.
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

  def settings = @settings ||= Settings.new(**super)

  def width = settings.width
  def height = settings.height
  def mines = settings.mines
  def dimensions = settings.dimensions

  def pattern_name = settings.name
  def pattern? = settings.pattern?
  def pattern = @pattern ||= Pattern.find_by!(name: pattern_name)

  def cells_at(coordinates_set)
    coordinates_set = Conversions.CoordinatesSet(coordinates_set)
    cells.select { |cell| coordinates_set.include?(cell.coordinates) }
  end

  def mines_placed? = cells.any?(&:mine?)
  def flags_count = cells.count(&:flagged?)

  def grid
    Grid.new(cells)
  end

  private

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
        value: nil,
      )

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
        value: nil,
      )

      self
    end
  end
end
