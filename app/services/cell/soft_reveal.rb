# frozen_string_literal: true

# Cell::SoftReveal manipulates the given {Cell}'s attributes to present it as
# revealed, without actually saving/updating the {Cell} record.
class Cell::SoftReveal
  def self.call(...) = new(...).call

  def initialize(cell)
    @cell = cell
  end

  def call
    return if revealed?

    do_reveal

    cell
  end

  private

  attr_reader :cell

  def revealed? = cell.revealed?

  def do_reveal
    cell.revealed = true
    cell.highlighted = false
    cell.flagged = false
    cell.value = neighboring_mines_count
  end

  def neighboring_mines_count = neighbors.mines_count
  def neighbors = Cell::Neighbors.new(cell:)
end
