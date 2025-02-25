# frozen_string_literal: true

# Games::Current::Board::Cells::Behaviors abstracts the basic contextual
# methods used by the various Cells controllers.
module Games::Current::Board::Cells::Behaviors
  private

  def game
    @game ||=
      Game.for_game_on_statuses.for_id(params[:game_id]).
        eager_load(:board).
        take!
  end

  def board
    @board ||= game.board
  end

  def cell
    @cell ||= begin
      cell_id = params[:cell_id]
      board.cells.to_a.detect { |cell| cell.to_param == cell_id }.tap { |cell|
        unless cell
          raise(
            ActiveRecord::RecordNotFound,
            "#{game.identify}->#{board.identify}->Cell[#{cell_id.inspect}] "\
            "not found")
        end
      }
    end
  end
end
