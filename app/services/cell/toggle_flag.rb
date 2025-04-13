# frozen_string_literal: true

# Cell::ToggleFlag updates the given {Cell} record to a flagged state.
class Cell::ToggleFlag
  def self.call(...) = new(...).call

  def initialize(cell)
    @cell = cell
  end

  def call
    return if revealed?

    do_toggle_flag

    cell
  end

  private

  attr_reader :cell

  def revealed? = cell.revealed?

  def do_toggle_flag
    cell.update!(flagged: !cell.flagged?)
  end
end
