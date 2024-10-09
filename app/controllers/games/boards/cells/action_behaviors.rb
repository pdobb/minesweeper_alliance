# frozen_string_literal: true

# Games::Boards::Cells::ActionBehaviors is a Controller mix-in for Controllers
# that need to operate on {Board}s and their associated {Cell}s.
module Games::Boards::Cells::ActionBehaviors
  # Games::Boards::Cells::ActionBehaviors::Error represents any StandardError
  # related to Game / Board / Cell Actions processing.
  Error = Class.new(StandardError)

  private

  def game
    @game ||= Game.find(params[:game_id])
  end

  def board
    game.board
  end

  def cell
    @cell ||= begin
      cell_id = params[:cell_id]
      board.cells.to_a.detect { |cell| cell.to_param == cell_id }.tap { |cell|
        unless cell
          raise(Error, "couldn't find Cell with id #{cell_id.inspect}")
        end
      }
    end
  end

  def broadcast_changes
    DutyRoster.cleanup
    WarRoomChannel.broadcast_refresh_to(:current_game)

    if game.just_ended? # rubocop:disable Style/GuardClause
      Turbo::StreamsChannel.broadcast_refresh_to(:sweep_ops_archive)
    end
  end

  def render_updated_game_board
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.turbo_stream { render("games/boards/cells/update_game_board") }
    end
  end

  def current_context
    CurrentContext.new(self)
  end

  # Games::Boards::Cells::ActionBehaviors::CurrentContext
  class CurrentContext
    def initialize(context)
      @context = context
    end

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)

    def user = context.current_user

    private

    attr_reader :context
  end
end
