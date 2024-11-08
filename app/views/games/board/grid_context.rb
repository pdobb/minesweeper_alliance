# frozen_string_literal: true

# Games::Board::GridContext wraps the current view context (i.e. the view
# template) with a specialized set of additional features for {Board} rendering
# for current/just-ended/past {Game}s.
class Games::Board::GridContext
  MOBILE_VIEW_DISPLAY_WIDTH_IN_COLUMNS = 10

  def initialize(context:, board:)
    @context = context
    @board = board
  end

  def transpose?
    mobile? && transposable? && (landscape? && too_wide_for_mobile?)
  end

  private

  attr_reader :context,
              :board

  def mobile? = context.mobile?

  def transposable? = !board_settings.pattern?
  def board_settings = board.settings

  def landscape? = width >= height
  def too_wide_for_mobile? = wider_than?(MOBILE_VIEW_DISPLAY_WIDTH_IN_COLUMNS)
  def wider_than?(value) = width > value
  def width = board_settings.width
  def height = board_settings.height
end
