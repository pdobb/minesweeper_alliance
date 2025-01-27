# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors is a Controller mix-in for
# Controllers that need to operate on {Board}s and their associated {Cell}s.
module Games::Current::Board::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  included do
    include AllowBrowserBehaviors
  end

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

  def broadcast_updates(...)
    if game.just_ended?
      broadcast_just_ended_game_updates
      broadcast_past_games_index_refresh
    else
      broadcast_current_game_updates(...)
    end

    respond_with { head(:no_content) }
  end

  def broadcast_current_game_updates(updated_cells)
    FleetTracker.activate!(current_user_token)

    WarRoomChannel.broadcast([
      (yield if block_given?), # Cell Action Controller-specific updates.
      Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:),
    ])
  end

  def current_user_token = current_context.user_token

  def broadcast_just_ended_game_updates
    container = Games::JustEnded::Container.new(game:)
    target = container.turbo_frame_name
    html =
      render_to_string(
        partial: "games/just_ended/container", locals: { container: })

    WarRoomChannel.broadcast_replace(target:, html:)
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

  def current_context = CurrentContext.new(self)

  # Games::Current::Board::Cells::ActionBehaviors::CurrentContext
  class CurrentContext
    def initialize(context)
      @context = context
    end

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)

    def user = context.current_user
    def user_token = user.token

    private

    attr_reader :context
  end
end
