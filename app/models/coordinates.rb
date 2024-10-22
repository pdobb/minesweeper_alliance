# frozen_string_literal: true

# Coordinates represents an X/Y pair. e.g. {Cell}s can locate themselves within
# the {Board} by their Coordinates.
#
# Coordinates can be used in Ranges along a row.
#   Coordinates[0, 0]..Coordinates[30, 0] # => (0, 0), (1, 0), ... (30, 0)
#
# Coordinates are Comparable (sortable, etc.)
#   (Coordinates[0, 0]..Coordinates[30, 0]).shuffle
class Coordinates < Data.define(:x, :y) # rubocop:disable Style/DataInheritance
  include Comparable
  include ConsoleBehaviors

  # :reek:DuplicateMethodCall
  # rubocop:disable all

  def neighbors
    [
      with(x: x.pred, y: y.pred), with(y: y.pred), with(x: x.next, y: y.pred),
      with(x: x.pred           ),                  with(x: x.next           ),
      with(x: x.pred, y: y.next), with(y: y.next), with(x: x.next, y: y.next),
    ]
  end

  # rubocop:enable all

  # Allow sorting with other Coordinates objects.
  def <=>(other)
    unless other.is_a?(self.class) || other.is_a?(self.class::Console)
      raise(
        TypeError,
        "can't compare with non-Coordinates objects, got #{other.class}")
    end

    [y, x] <=> [other.y, other.x]
  end

  # Allow ranges of Coordinates along a row.
  def succ
    with(x: x.next)
  end

  def to_a
    [x, y]
  end

  # Coordinates::Console acts like a {Coordinates} but otherwise handles IRB
  # Console-specific methods/logic.
  class Console
    BEGINNER_DIFFICULTY_LEVEL_CELLS_COUNT = 81

    include ConsoleObjectBehaviors

    def x = __model__.x
    def y = __model__.y

    def render(cells_count:)
      "(#{pad(x, cells_count:)}, #{pad(y, cells_count:)})"
    end

    def to_s
      inspect
    end

    private

    def inspect
      "(#{x}, #{y})"
    end

    def pad(value, cells_count:)
      return value if cells_count <= BEGINNER_DIFFICULTY_LEVEL_CELLS_COUNT

      value.to_s.rjust(2, " ")
    end
  end
end
