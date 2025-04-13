# frozen_string_literal: true

# :reek:MissingSafeMethod

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
  def flagged? = cell.flagged?
  def update!(...) = cell.update!(...)

  def do_toggle_flag
    flagged? ? unset_flag : set_flag
  end

  def set_flag
    update!(
      flagged: true,
      highlighted: false)
  end

  def unset_flag
    update!(flagged: false)
  end
end
