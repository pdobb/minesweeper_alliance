# frozen_string_literal: true

# Games::Boards::Cells::ActionBehaviors is a Controller mix-in for Controllers
# that need to operate on {Board}s and their associated {Cell}s.
module Games::Boards::Cells::ActionBehaviors
  private

  def broadcast_changes(stream: :current_game)
    Turbo::StreamsChannel.broadcast_refresh_to(stream)
  end

  def render_updated_game_board
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.turbo_stream { render("games/boards/cells/update_game_board") }
    end
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

  def current_context
    CurrentContext.new(self)
  end

  class CurrentContext
    def initialize(context)
      @context = context
    end

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)

    def user = layout.current_user
    def layout = context.layout

    private

    attr_reader :context
  end
end
