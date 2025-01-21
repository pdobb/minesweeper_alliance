# frozen_string_literal: true

# Games::Current::Board::Cell represents {Cell}s for the current {Game}.
class Games::Current::Board::Cell
  BG_HIGHLIGHTED_COLOR = %w[bg-slate-300 dark:bg-neutral-500].freeze
  HIGHLIGHTED_ANIMATION = "animate-pulse-fast"
  BG_UNREVEALED_MINE_COLOR = %w[bg-slate-500 dark:bg-neutral-900].freeze

  include Games::Board::CellBehaviors

  def initialize(cell)
    @cell = cell
  end

  def dom_id = View.dom_id(cell)

  def css
    return if revealed?

    if highlighted?
      [*BG_HIGHLIGHTED_COLOR, HIGHLIGHTED_ANIMATION]
    elsif mine? && App.debug?
      BG_UNREVEALED_MINE_COLOR
    else
      BG_UNREVEALED_CELL_COLOR
    end
  end

  private

  attr_reader :cell

  def highlighted? = cell.highlighted?
end
