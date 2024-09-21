# frozen_string_literal: true

# Grid allows for organizing an Array of {Cell}s. Outputs include: a Hash, an
# Array of Arrays, or any such Enumerable method result.
class Grid
  STANDARD_ORGANIZER = ->(array) { array }
  TRANSPOSE_ORGANIZER = ->(array) { array.transpose }

  MOBILE_VIEW_DISPLAY_WIDTH_IN_COLUMNS = 10

  include Enumerable
  include ConsoleBehaviors

  attr_reader :cells,
              :context

  # :reek:ManualDispatch
  def initialize(cells, context: nil)
    @cells = Array.wrap(cells)
    @context = context
  end

  def cells_count = cells.size

  # rubocop:disable Layout/LineLength

  # Group {#cells} into an Array Index-mapped Hash.
  #
  # @return [Hash]
  #
  # @example
  #   {
  #     0=>[<Cell[1](◻️) (0, 0) :: nil>, <Cell[2](◻️) (1, 0) :: nil>, <Cell[3](◻️ / 💣) (2, 0) :: nil>],
  #     1=>[<Cell[4](◻️) (0, 1) :: nil>, <Cell[5](◻️) (1, 1) :: nil>, <Cell[6](◻️ / 💣) (2, 1) :: nil>],
  #     2=>[<Cell[7](◻️) (0, 2) :: nil>, <Cell[8](◻️) (1, 2) :: nil>, <Cell[9](◻️ / 💣) (2, 2) :: nil>]
  #   }
  def to_h
    @to_h ||= cells.group_by { |cell| cell.y || "nil" }
  end

  # Allow rows enumeration. e.g. this provides Grid#to_a and Grid#map via the Enumerable mix-in.
  #
  # @return [Enumerable]
  #
  # @example #to_a
  #   @example
  #     [
  #       [<Cell[1](◻️) (0, 0) :: nil>, <Cell[2](◻️) (1, 0) :: nil>, <Cell[3](◻️ / 💣) (2, 0) :: nil>],
  #       [<Cell[4](◻️) (0, 1) :: nil>, <Cell[5](◻️) (1, 1) :: nil>, <Cell[6](◻️ / 💣) (2, 1) :: nil>],
  #       [<Cell[7](◻️) (0, 2) :: nil>, <Cell[8](◻️) (1, 2) :: nil>, <Cell[9](◻️ / 💣) (2, 2) :: nil>]
  #     ]
  def each(&)
    organizer.(to_h.values).each(&)
  end

  private

  def organizer
    return STANDARD_ORGANIZER unless context&.mobile?

    if landscape? && wider_than?(MOBILE_VIEW_DISPLAY_WIDTH_IN_COLUMNS)
      TRANSPOSE_ORGANIZER
    else
      STANDARD_ORGANIZER
    end
  end

  def landscape?
    width >= height
  end

  def wider_than?(value)
    width > value
  end

  def width
    @width ||= to_h.values.first.size
  end

  def height
    @height ||= to_h.keys.size
  end

  # rubocop:enable Layout/LineLength

  # Grid::Console acts like a {Grid} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def cells = super.map(&:console)

    def to_h
      super.transform_values { |row| row.map(&:console) }
    end

    def to_a
      super.map { |row| row.map(&:console) }
    end

    # @example
    #   0 => ◻️ (0, 0) ◻️ (1, 0) ◻️ (2, 0)
    #   1 => ◻️ (0, 1) ◻️ (1, 1) ◻️ (2, 1)
    #   2 => ◻️ (0, 2) ◻️ (1, 2) ◻️ (2, 2)
    def render
      to_h.each do |y, row|
        render_row(y:, row:)
      end

      nil
    end

    private

    def inspect_identification = __model__.class.name

    def inspect_info
      "#{Icon.cell} x#{cells_count} (#{dimensions})"
    end

    def dimensions
      "#{count}x#{to_a.first.size}"
    end

    # rubocop:disable Rails/Output
    def render_row(y:, row:)
      print "#{pad(y)}: "

      row.each do |cell|
        print cell.console.render(cells_count:), " "
      end

      print "\n"
    end
    # rubocop:enable Rails/Output

    def pad(value)
      value.to_s.rjust(2, " ")
    end
  end
end
