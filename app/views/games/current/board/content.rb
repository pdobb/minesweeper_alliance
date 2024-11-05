# frozen_string_literal: true

# Games::Current::Board::Content represents the actual {Board} content for the
# current {Game}.
class Games::Current::Board::Content
  NULL_CELL_ID = 0

  def initialize(board:)
    @board = board
  end

  def grid_context(context)
    @grid_context ||= Games::Board::GridContext.new(context:, board:)
  end

  def reveal_url
    Router.game_board_cell_reveal_path(game, NULL_CELL_ID)
  end

  def toggle_flag_url
    Router.game_board_cell_toggle_flag_path(game, NULL_CELL_ID)
  end

  def highlight_neighbors_url
    Router.game_board_cell_highlight_neighbors_path(game, NULL_CELL_ID)
  end

  def reveal_neighbors_url
    Router.game_board_cell_reveal_neighbors_path(game, NULL_CELL_ID)
  end

  def rows(context:)
    grid(context:).map { |row| Games::Current::Board::Cell.wrap(row, game:) }
  end

  private

  attr_reader :board

  def game = @game ||= board.game
  def game_on? = game.on?

  def grid(context:)
    @grid ||= board.grid(context:)
  end
end
