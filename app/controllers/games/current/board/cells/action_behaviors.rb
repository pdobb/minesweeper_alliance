# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors is a Controller mix-in for
# Controllers that need to operate on {Board}s and their associated {Cell}s.
module Games::Current::Board::Cells::ActionBehaviors
  # Games::Current::Board::Cells::ActionBehaviors::Error represents any
  # StandardError related to Game / Board / Cell Actions processing.
  Error = Class.new(StandardError)

  private

  def current_game
    @current_game ||= begin
      game_id = params[:game_id]
      Game.for_game_on_statuses.for_id(game_id).take.tap { |game|
        unless game
          raise(Error, "Current Game with ID #{game_id.inspect} not found")
        end
      }
    end
  end

  def board
    @board ||= current_game.board
  end

  def cell
    @cell ||= begin
      cell_id = params[:cell_id]
      board.cells.to_a.detect { |cell| cell.to_param == cell_id }.tap { |cell|
        raise(Error, "Cell with ID #{cell_id.inspect} not found") unless cell
      }
    end
  end

  def broadcast_changes
    DutyRoster.cleanup
    WarRoomChannel.broadcast_refresh

    if current_game.just_ended? # rubocop:disable Style/GuardClause
      Turbo::StreamsChannel.broadcast_refresh_to(Games::Index.turbo_stream_name)
    end
  end

  def render_updated_game
    if current_game.just_ended?
      render_updated_just_ended_game
    else
      render_updated_current_game_content
    end
  end

  def render_updated_just_ended_game
    render_update do
      @view = Games::JustEnded::Update.new(current_game:)
      render("games/just_ended/update")
    end
  end

  def render_updated_current_game_content
    render_update do
      @view = Games::Current::Update.new(current_game:)
      render("games/current/update")
    end
  end

  def render_update(&)
    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.turbo_stream(&)
    end
  end

  def current_context
    CurrentContext.new(self)
  end

  # Games::Current::Board::Cells::ActionBehaviors::CurrentContext
  class CurrentContext
    def initialize(context)
      @context = context
    end

    def game = context.__send__(:current_game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)

    def user = context.current_user

    private

    attr_reader :context
  end
end
