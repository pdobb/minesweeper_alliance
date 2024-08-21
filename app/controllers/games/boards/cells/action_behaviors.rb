# frozen_string_literal: true

# Games::Boards::Cells::ActionBehaviors is a Controller mix-in for Controllers
# that need to operate on {Board}s and their associated {Cell}s.
module Games::Boards::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  private

  def render_updated_game_board
    render(
      partial: "games/game",
      locals: { game: GamesController::GameView.new(game) })
  end

  def game
    @game ||= Game.find(params[:game_id])
  end

  def board
    game.board
  end

  def cell
    @cell ||= board.cells.find(params[:cell_id])
  end
end
