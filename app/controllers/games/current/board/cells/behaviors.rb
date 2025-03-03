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
    @cell ||= begin
      id_string = params[:cell_id]
      cells_arel.to_a.detect { |cell| cell.id?(id_string) }.tap { |cell|
        raise(ActiveRecord::RecordNotFound, inspect_cell_lineage) unless cell
      }
    end
  end

  def cells_arel
    arel = board.cells
    arel = arel.readonly if game.over?
    arel
  end

  def inspect_cell_lineage
    "#{game.identify} -> #{board.identify} -> Cell[#{params[:cell_id].inspect}]"
  end
end
