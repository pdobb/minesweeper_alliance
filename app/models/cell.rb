class Cell < ApplicationRecord
  belongs_to :board

  serialize :coordinates, coder: CoordinatesCoder

  delegate :x,
           :y,
           to: :coordinates

  scope :for_coordinates, ->(coordinates) { where(coordinates:) }

  scope :by_coordinates_asc, -> {
    order(Arel.sql("coordinates->>'y'").asc).
      order(Arel.sql("coordinates->>'x'").asc)
  }

  def neighbors
    board.cells.for_coordinates(neighboring_coordinates).by_coordinates_asc
  end

  def neighboring_coordinates_grid
    Grid.new(neighboring_coordinates)
  end

  def neighboring_coordinates
    board.clamp_coordinates(coordinates.neighbors)
  end

  private

  def inspect_identification
    "Cell"
  end

  def inspect_flags
    ["💣", "◻️"].sample
  end

  def inspect_info
    coordinates.inspect
  end
end
