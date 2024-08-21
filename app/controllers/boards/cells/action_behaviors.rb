# frozen_string_literal: true

# Boards::Cells::ActionBehaviors is a Controller mix-in for Controllers that
# need to operate on {Board}s and their associated {Cell}s.
module Boards::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  private

  def render_updated_game_board
    render(
      partial: "games/game",
      locals: { game: GamesController::GameView.new(game) })
  end

  def game
    Game.find(game_id)
  end

  def board
    Board.find(params[:board_id])
  end

  def cell
    board.cells.find(params[:cell_id])
  end

  def game_id
    board.game_id
  end
end
