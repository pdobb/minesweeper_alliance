# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors is a Controller mix-in for
# Controllers that need to operate on {Board}s and their associated {Cell}s.
module Games::Current::Board::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  included do
    include AllowBrowserBehaviors

    before_action :require_participant
  end

  private

  def require_participant
    return if current_user.participant?

    CreateParticipant.(game:, context: self)
    generate_user_nav_turbo_stream_update_action
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

    turbo_stream_actions <<
      turbo_stream.replace(
        nav.turbo_target,
        method: :morph,
        partial: "current_user/nav",
        locals: { nav: })
  end

  def broadcast_updates(...)
    if game.just_ended?
      broadcast_just_ended_game_updates
      broadcast_past_games_index_refresh
    else
      broadcast_current_game_updates(...)
    end
  end

  def broadcast_current_game_updates(updated_cells)
    FleetTracker.activate!(current_user_token)

    content = [
      (yield if block_given?), # Cell Action Controller-specific updates.
      Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:),
    ].join

    WarRoomChannel.broadcast(content)
    respond_with {
      render(turbo_stream: turbo_stream_actions.push(content))
    }
  end

  def current_user_token = context.user_token

  # :reek:TooManyStatements
  def broadcast_just_ended_game_updates
    container = Games::JustEnded::Container.new(game:)
    target = container.turbo_frame_name
    html =
      render_to_string(
        partial: "games/just_ended/container", locals: { container: })
    # Can't use `:morph` here or
    # app/javascript/controllers/games/just_ended/new_game_content_controller.js
    # will fail to remove the "Custom" button for non-signers on the 2nd
    # rendering (from the broadcast).
    content = turbo_stream.replace(target, html:)

    WarRoomChannel.broadcast(content)
    respond_with {
      render(turbo_stream: turbo_stream_actions.push(content))
    }
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

  # Games::Current::Board::Cells::ActionBehaviors::CreateParticipant
  # - Creates the "Current {User}" to which this Cell Action will be associated
  # - Creates an active {ParticipantTransaction} between the new {User} and the
  #   passed-in {Game}
  class CreateParticipant
    include CallMethodBehaviors

    def initialize(game:, context:)
      @game = game
      @context = context
    end

    def call
      context.current_user_will_change

      User.transaction do
        User::Current::Create.(context: CreateUserContext.new(context))
        ParticipantTransaction.create_active_between(user: current_user, game:)
        FleetTracker.add!(current_user.token)
      end
    end

    private

    attr_reader :game,
                :context

    def current_user = context.current_user
    def cookies = context.__send__(:cookies)

    # Games::Current::Board::Cells::ActionBehaviors::CreateParticipant::CreateUserContext
    # services the needs of {User::Current::Create}.
    class CreateUserContext
      def initialize(context) = @context = context
      def layout = context.layout

      def user_agent = layout.user_agent
      def store_signed_cookie(...) = layout.store_signed_cookie(...)
      def delete_cookie(...) = layout.cookies.delete(...)

      private

      attr_reader :context
    end
  end
end
