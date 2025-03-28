# frozen_string_literal: true

# Board::Calc3BV is a Service Object for calculating the 3BV value (3BV is
# a.k.a. Bechtel's Board Benchmark Value) for a given Game {Board} / {Grid}.
#
# A 3BV value is a measure of board difficulty. It represents the minimum number
# of left clicks required to win a Game:
# - Each opening requires 1 click, and
# - Each non-mine, numbered {Cell} that doesn't touch an opening requires at 1
#   click.
#
# @see https://minesweepergame.com/statistics.php
class Board::Calc3BV
  include ConsoleBehaviors

  attr_reader :grid

  def self.call(...) = new(...).call

  def initialize(grid)
    @grid = grid
  end

  def call
    process_cells
    count
  end

  def cells_at(coordinates_array)
    cells.select { |cell| coordinates_array.include?(cell.coordinates) }
  end

  private

  def cells
    @cells ||= grid.to_a.flat_map { |row| Cell.wrap(row, calculator: self) }
  end

  def process_cells
    cells.each(&:process_openings)
    cells.each(&:process)
  end

  def count = cells.sum(&:count)

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    private

    def inspect_identification = identify(:grid)
  end

  # :reek:InstanceVariableAssumption

  # Board::Calc3BV::Cell wraps {Cell} for performing 3BV scoring functions.
  class Cell
    include WrapMethodBehaviors

    delegate_missing_to :to_model

    def initialize(cell, calculator:)
      @cell = cell
      @calculator = calculator
    end

    def to_model = @cell.console

    def process_openings
      return if visited? || mine?
      return if !blank? # rubocop:disable Style/NegatedIf, Rails/Present

      mark_as_visited
      mark_as_click_needed

      visit_neighbors
    end

    def visit_neighbors = neighbors.each(&:visit_neighbor)

    def visit_neighbor
      return if visited?

      mark_as_visited
      visit_neighbors if blank?
    end

    def process
      return if visited? || mine?

      mark_as_visited
      mark_as_click_needed
    end

    def blank? = value == ::Cell::BLANK_VALUE
    def mark_as_visited = @visited = true
    def visited? = !!@visited
    def mark_as_click_needed = @count = 1
    def count = @count.to_i

    private

    attr_reader :calculator

    def neighbors = calculator.cells_at(neighboring_coordinates)
    def neighboring_coordinates = coordinates.neighbors

    concerning :ObjectInspection do
      include ObjectInspectionBehaviors

      private

      def inspect_flags(scope:)
        scope.join_flags([
          (Emoji.mine if mine?),
          (visited? ? Emoji.eyes : Emoji.hide),
        ])
      end

      def inspect_name = @count.inspect
    end
  end

  # Board::Calc3BV::Console acts like a {Board::Calc3BV} but otherwise handles
  # IRB Console-specific methods/logic.
  class Console
    include ConsoleObjectBehaviors

    # @example
    #   Board::Calc3BV.new(Board.last.grid).cons.call
    def call
      process_cells
      count
    end

    def process_cells
      super.tap {
        pp(render)
      }
    end

    # Show where the clicks came from.
    #
    # @example
    #   # Compare output against `calc.grid.render`:
    #   Board::Calc3BV.new(Board.last.grid).cons.render
    def render
      cells.map(&:count).in_groups_of(grid.columns_count)
    end

    def grid = super.console

    concerning :ObjectInspection do
      include ObjectInspectionBehaviors

      private

      def inspect_identification = identify(:grid, class: __class__)
    end
  end
end
