class Cell < ApplicationRecord
  Error = Class.new(StandardError)

  belongs_to :board

  serialize :coordinates, coder: CoordinatesCoder

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

  def self.place_mines(cells)
    raise Error, "mines have already been placed" if cells.is_a_mine.any?

    cells.update_all(mine: true)
  end

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
    mine? ? "💣" : "◻️"
  end

  def inspect_info
    coordinates.inspect
  end
end
