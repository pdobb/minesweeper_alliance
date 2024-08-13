class Cell < ApplicationRecord

  belongs_to :board

  attribute :coordinates, CoordinatesType.new
  delegate :x,
           :y,
           to: :coordinates

  scope :is_a_mine, -> { where(mine: true) }

  scope :for_coordinates, ->(coordinates) { where(coordinates:) }

  scope :by_coordinates_asc, -> {
    order(Arel.sql("coordinates->>'y'").asc).
      order(Arel.sql("coordinates->>'x'").asc)
  }
  scope :by_random, -> { order("RANDOM()") }

  def neighbors
    board.cells.for_coordinates(neighboring_coordinates).by_coordinates_asc
  end

  def neighboring_coordinates_grid
    Grid.new(neighboring_coordinates)
  end

  def neighboring_coordinates
    board.clamp_coordinates(coordinates.neighbors)
  end

  def render
    "#{inspect_flags} #{coordinates.render}"
  end

  private

  def inspect_identification
    identify
  end

  def inspect_flags
    mine? ? "💣" : "◻️"
  end

  def inspect_info
    coordinates.inspect
  end
end
