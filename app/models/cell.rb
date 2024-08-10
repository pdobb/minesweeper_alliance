class Cell < ApplicationRecord
  belongs_to :board

  serialize :coordinates, coder: CoordinatesCoder

  delegate :x,
           :y,
           to: :coordinates

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
