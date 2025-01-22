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
    yield.tap {
      FleetTracker.activate!(token: current_user_token)
    }
  rescue Error
    flash[:warning] = t("flash.web_socket_lost")
    recover_from_exception
  rescue => ex
    Notify.(ex)
    recover_from_exception
  end

  def current_user_token = current_context.user_token

  def recover_from_exception
    respond_with do
      render(turbo_stream: turbo_stream.refresh(request_id: nil))
    end
  end

  def broadcast_updates(updated_cells)
    if current_game.just_ended?
      broadcast_just_ended_game_updates
      broadcast_past_games_index_refresh
    else
      broadcast_current_game_updates(updated_cells)
    end
  end

  def broadcast_current_game_updates(updated_cells)
    WarRoomChannel.broadcast(
      Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:))

    respond_with { head(:no_content) }
  end

  # :reek:TooManyStatements
  def broadcast_just_ended_game_updates
    container = Games::JustEnded::Container.new(current_game:)
    target = container.turbo_frame_name
    html =
      render_to_string(
        partial: "games/just_ended/container", locals: { container: })

    WarRoomChannel.broadcast_replace(target:, html:)
    respond_with { head(:no_content) }
  end

  def broadcast_past_games_index_refresh
    Turbo::StreamsChannel.broadcast_refresh_later_to(
      Games::Index.turbo_stream_name)
  end

  def respond_with(&)
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
    def user_token = user.token

    private

    attr_reader :context
  end
end
