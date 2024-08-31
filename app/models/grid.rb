# frozen_string_literal: true

# Grid allows for organizing an Array of {Cell}s. Outputs include: a Hash, an
# Array of Arrays, or "rendering" the grid by appealing to {Cell#render}.
class Grid
  include ConsoleBehaviors

  attr_reader :cells

  def initialize(cells)
    @cells = cells
  end

  # rubocop:disable Layout/LineLength
  # @example
  #   {
  #     0=>[<Cell[1](◻️) (0, 0) :: nil>, <Cell[2](◻️) (1, 0) :: nil>, <Cell[3](◻️ / 💣) (2, 0) :: nil>],
  #     1=>[<Cell[4](◻️) (0, 1) :: nil>, <Cell[5](◻️) (1, 1) :: nil>, <Cell[6](◻️ / 💣) (2, 1) :: nil>],
  #     2=>[<Cell[7](◻️) (0, 2) :: nil>, <Cell[8](◻️) (1, 2) :: nil>, <Cell[9](◻️ / 💣) (2, 2) :: nil>]
  #   }
  # rubocop:enable Layout/LineLength
  def to_h
    cells.group_by { |cell| cell.y || "nil" }
  end

  # rubocop:disable Layout/LineLength
  # @example
  #   [
  #     [<Cell[1](◻️) (0, 0) :: nil>, <Cell[2](◻️) (1, 0) :: nil>, <Cell[3](◻️ / 💣) (2, 0) :: nil>],
  #     [<Cell[4](◻️) (0, 1) :: nil>, <Cell[5](◻️) (1, 1) :: nil>, <Cell[6](◻️ / 💣) (2, 1) :: nil>],
  #     [<Cell[7](◻️) (0, 2) :: nil>, <Cell[8](◻️) (1, 2) :: nil>, <Cell[9](◻️ / 💣) (2, 2) :: nil>]
  #   ]
  # rubocop:enable Layout/LineLength
  def to_a
    to_h.values
  end

  def cells_count = cells.size

  # Grid::Console acts like a {Grid} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def to_h
      __to_model__.to_h.transform_values { |row|
        row.map(&:console)
      }
    end

    def to_a
      __to_model__.to_a.map { |row|
        row.map(&:console)
      }
    end

    # @example
    #   0 => ◻️ (0, 0) ◻️ (1, 0) ◻️ (2, 0)
    #   1 => ◻️ (0, 1) ◻️ (1, 1) ◻️ (2, 1)
    #   2 => ◻️ (0, 2) ◻️ (1, 2) ◻️ (2, 2)
    def render
      to_h.each do |column_number, row|
        render_row(column_number:, row:)
      end

      nil
    end

    private

    def inspect_identification = "Grid"
    def inspect_info = "#{Icon.cell} x #{cells_count}"

    # :reek:TooManyStatements
    # :reek:DuplicateMethodCall
    # rubocop:disable Rails/Output
    def render_row(column_number:, row:)
      print "#{pad(column_number)} => "

      row.each do |cell|
        result = cell.console.render(cells_count:)
        # Not sure why the results aren't consistent, but sometimes there isn't
        # a space between the {Icon.cell} and the start of Coordinates
        # rendering (See {Cell::Console#render}). It seems to just be how
        # Emojis are handled in Strings sometimes...
        result.gsub!("#{Icon.cell}(", "#{Icon.cell} (")
        print result
      end

      print "\n"
    end
    # rubocop:enable Rails/Output

    # :reek:UtilityFunction
    def pad(value)
      value.to_s.rjust(2, " ")
    end
  end
end
