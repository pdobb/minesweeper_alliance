# frozen_string_literal: true

# Games::Current::Board::Cells::Behaviors abstracts the basic contextual
# methods used by the various Cells controllers.
module Games::Current::Board::Cells::Behaviors
  private

  def game
    @game ||= Game.for_id(params[:game_id]).eager_load(:board).take!
  end

  def board
    @board ||= game.board
  end

  def cell
    @cell ||= Game::Board::Cell::Find.(game:, cell_id: params[:cell_id])
  end
end
