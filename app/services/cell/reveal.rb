# frozen_string_literal: true

# Cell::Reveal updates the given {Cell} record to a revealed state.
class Cell::Reveal
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
    soft_reveal.tap(&:save!)
  end

  def soft_reveal = Cell::SoftReveal.(cell)
end
