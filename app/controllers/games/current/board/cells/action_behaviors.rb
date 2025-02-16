# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors abstracts the basic contextual
# methods used by the various Cell Action controllers.
module Games::Current::Board::Cells::ActionBehaviors
  private

  def game
    @game ||= Game.for_game_on_statuses.for_id(params[:game_id]).take!
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

  def context = ActionContext.new(self)

  # Games::Current::Board::Cells::ActionBehaviors::ActionContext services the
  # needs of the Cell Action service objects called by including controllers.
  class ActionContext
    def initialize(context) = @context = context

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)
    def user = context.current_user

    private

    attr_reader :context
  end
end
