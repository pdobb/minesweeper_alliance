# frozen_string_literal: true

# Games::Current::Board::Content represents the actual {Board} content for the
# current {Game}.
class Games::Current::Board::Content
  NULL_CELL_ID = 0

  def initialize(board:)
    @board = board
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

  def rows
    grid.map { |row| Games::Current::Board::Cell.wrap(row, game:) }
  end

  def mobile?(context) = context.mobile?

  private

  attr_reader :board

  def game
    @game ||= board.game
  end

  def game_on? = game.on?

  def grid = board.grid
end
