# frozen_string_literal: true

# Pattern::Cell is a virtual object representing the given {Coordinates} for the
# given {Pattern}.
class Pattern::Cell
  attr_reader :coordinates

  def initialize(pattern:, coordinates:)
    @pattern = pattern
    @coordinates = coordinates
  end

  def x = coordinates.x
  def y = coordinates.y

  def flagged?
    pattern.flagged?(coordinates)
  end

  private

  attr_reader :pattern
end
