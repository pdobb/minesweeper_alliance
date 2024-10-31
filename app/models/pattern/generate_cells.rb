# frozen_string_literal: true

# Pattern::GenerateCells generates an in-memory array of "Cells"--used as a
# virtual {Grid} for flagging {Coordinates}.
class Pattern::GenerateCells
  include CallMethodBehaviors

  def initialize(pattern:)
    @pattern = pattern
  end

  def call
    cell_data
  end

  private

  attr_reader :pattern

  def cell_data
    (0...total).map { |index| build_for(index) }
  end

  def build_for(index)
    coordinates = build_coordinates_for(index)

    Pattern::Cell.new(pattern:, coordinates:)
  end

  def build_coordinates_for(index)
    x = index % width
    y = index / width
    Coordinates[x, y]
  end

  def total = width * height
  def width = pattern.width
  def height = pattern.height
end
