# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors is a Controller mix-in for
# Controllers that need to operate on {Board}s and their associated {Cell}s.
module Games::Current::Board::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  # Games::Current::Board::Cells::ActionBehaviors::Error represents any
  # StandardError related to Game / Board / Cell Actions processing.
  Error = Class.new(StandardError)

  included do
    include AllowBrowserBehaviors
  end

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

  # :reek:TooManyStatements
  def safe_perform_game_action
    yield
  rescue => ex
    Notify.(ex)
    flash[:warning] = t("flash.web_socket_lost")

    render_update do
      render(turbo_stream: turbo_stream.refresh(request_id: nil))
    end
  end

  def render_updated_game
    DutyRoster.cleanup

    if current_game.just_ended?
      render_just_ended_game
      broadcast_past_games_index_refresh
    else
      render_updated_current_game
    end
  end

  def broadcast_past_games_index_refresh
    Turbo::StreamsChannel.broadcast_refresh_later_to(
      Games::Index.turbo_stream_name)
  end

  # :reek:TooManyStatements
  def render_updated_current_game
    content = Games::Current::Content.new(current_game:)
    target = content.turbo_frame_name
    html =
      render_to_string(
        partial: "games/current/content", locals: { content: })

    WarRoomChannel.broadcast_replace(target:, html:)
    render_update do
      render(turbo_stream: turbo_stream.replace(target, html))
    end
  end

  # :reek:TooManyStatements
  def render_just_ended_game
    container = Games::JustEnded::Container.new(current_game:)
    target = container.turbo_frame_name
    html =
      render_to_string(
        partial: "games/just_ended/container", locals: { container: })

    WarRoomChannel.broadcast_replace(target:, html:)
    render_update do
      render(turbo_stream: turbo_stream.replace(target, html))
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
