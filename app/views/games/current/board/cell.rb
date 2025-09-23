# frozen_string_literal: true

# Games::Current::Board::Cell represents {Cell}s for the current {Game}.
class Games::Current::Board::Cell
  HIGHLIGHT_ORIGIN_COLOR = "text-blue-500"
  private_constant :HIGHLIGHT_ORIGIN_COLOR

  BG_HIGHLIGHTED_COLOR = %w[bg-slate-300 dark:bg-neutral-500].freeze
  private_constant :BG_HIGHLIGHTED_COLOR

  HIGHLIGHTED_ANIMATION = "animate-pulse-fast"
  private_constant :HIGHLIGHTED_ANIMATION

  BG_UNREVEALED_MINE_COLOR = %w[bg-slate-500 dark:bg-neutral-900].freeze
  private_constant :BG_UNREVEALED_MINE_COLOR

  include Games::Board::CellBehaviors

  def initialize(cell)
    @cell = cell
  end

  def dom_id = View.dom_id(cell)

  def css
    return HIGHLIGHT_ORIGIN_COLOR if highlight_origin?
    return if revealed?

    if highlighted?
      [*BG_HIGHLIGHTED_COLOR, HIGHLIGHTED_ANIMATION]
    elsif mine? && show_unrevealed_mine_hints?
      BG_UNREVEALED_MINE_COLOR
    else
      BG_UNREVEALED_CELL_COLOR
    end
  end

  private

  attr_reader :cell

  def highlighted? = cell.highlighted?
  def highlight_origin? = cell.highlight_origin?
  def show_unrevealed_mine_hints? = App.debug?
end
