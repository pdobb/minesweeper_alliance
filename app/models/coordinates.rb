# frozen_string_literal: true

# Coordinates represents an X/Y pair. e.g. {Cell}s can locate themselves within
# the {Board} by their Coordinates.
class Coordinates < Data.define(:x, :y) # rubocop:disable Style/DataInheritance
  include ConsoleBehaviors

  # :reek:DuplicateMethodCall

  # rubocop:disable Layout/MultilineArrayLineBreaks
  # rubocop:disable Layout/SpaceInsideParens
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Style/TrailingCommaInArrayLiteral
  def neighbors
    [
      with(x: x.pred, y: y.pred), with(y: y.pred), with(x: x.next, y: y.pred),
      with(x: x.pred           ),                  with(x: x.next           ),
      with(x: x.pred, y: y.next), with(y: y.next), with(x: x.next, y: y.next),
    ]
  end
  # rubocop:enable Style/TrailingCommaInArrayLiteral
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Layout/SpaceInsideParens
  # rubocop:enable Layout/MultilineArrayLineBreaks

  # Coordinates::Console acts like a {Coordinates} but otherwise handles IRB
  # Console-specific methods/logic.
  class Console
    BEGINNER_DIFFICULTY_LEVEL_CELLS_COUNT = 81

    include ConsoleObjectBehaviors

    def x = __to_model__.x
    def y = __to_model__.y

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
