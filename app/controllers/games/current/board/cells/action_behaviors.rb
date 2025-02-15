# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors is a Controller mix-in for
# Controllers that need to operate on {Board}s and their associated {Cell}s.
module Games::Current::Board::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  private

  def require_participant
    return if current_user.participant?

    Games::Current::CreateParticipant.(game:, context: self)
    turbo_stream_actions << generate_user_nav_turbo_stream_update_action
  end

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

  def turbo_stream_actions = @turbo_stream_actions ||= FlatArray.new

  def generate_user_nav_turbo_stream_update_action
    nav = CurrentUser::Nav.new(user: current_user)

    turbo_stream.replace(
      nav.turbo_target,
      method: :morph,
      partial: "current_user/nav",
      locals: { nav: })
  end

  def broadcast_updates(...)
    if game.just_ended?
      turbo_stream_actions << generate_just_ended_game_update_action
      enqueue_game_end_update_jobs
    else
      FleetTracker.activate!(current_user_token)
      turbo_stream_actions << generate_current_game_update_actions(...)
    end

    WarRoom::Responder.new(context: self).(turbo_stream_actions:)
  end

  def generate_current_game_update_actions(updated_cells)
    [
      (yield if block_given?), # Cell Action Controller-specific updates.
      Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:),
    ]
  end

  def current_user_token = context.user_token

  def generate_just_ended_game_update_action
    container = Games::JustEnded::Container.new(game:)
    target = container.turbo_frame_name
    html =
      render_to_string(
        partial: "games/just_ended/container", locals: { container: })
    # Can't use `:morph` here or
    # app/javascript/controllers/games/just_ended/new_game_content_controller.js
    # will fail to remove the "Custom" button for non-signers on the 2nd
    # rendering--as a result of the broadcast.

    turbo_stream.replace(target, html:)
  end

  def enqueue_game_end_update_jobs
    Game::Current::BroadcastWarRoomActivityIndicatorUpdateJob.perform_later
    Game::JustEnded::BroadcastNewBestsNotificationJob.perform_later(game)
    Turbo::StreamsChannel.broadcast_refresh_later_to(
      Games::Index.turbo_stream_name)
  end

  def context = Context.new(self)

  # Games::Current::Board::Cells::ActionBehaviors::Context services the needs
  # of the controllers that include this module.
  class Context
    def initialize(context) = @context = context

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)

    def user = context.current_user
    def user_token = user.token

    private

    attr_reader :context
  end
end
