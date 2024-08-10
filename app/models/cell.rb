class Cell < ApplicationRecord
  belongs_to :board

  private

  def inspect_identification
    "Cell"
  end

  def inspect_flags
    ["💣", "◻️"].sample
  end

  def inspect_info
    "#{x.to_i}, #{y.to_i}"
  end
end
