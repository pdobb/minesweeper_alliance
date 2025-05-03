# frozen_string_literal: true

# Games::Current::Board::Cells::DispatchAction:
# 1. Ensures an active participant ({User}) exists,
# 2. Yields a {Games::Current::Board::Cells::DispatchAction::Dispatch} object
#    for bundling action updates together and for defining {Game#status}-based
#    hooks,
# 3. Builds a primary Action response based on the current {Game#status},
# 4. Bundles together all of the Turbo Stream Actions generated throughout, and
# 5. Hands over the bundled Actions to {WarRoom::Responder} for
#    broadcast/delivery.
#
# DispatchAction is meant for handling active Cell Actions, which affect the
# {Game} play history. For passive Cell Actions, use
# {Games::Current::Board::Cells::DispatchEffect} instead.
class Games::Current::Board::Cells::DispatchAction
  # Games::Current::Board::Cells::DispatchAction::GameOverError
  GameOverError = Class.new(StandardError)

  def initialize(context:)
    @context = context
    @turbo_stream_actions = TurboStreamActions.new

    require_game_on
    require_participant
  end

  def call
    yield(Dispatch.new(turbo_stream_actions:, context:))

    generate_response
    activate_participant
  end

  private

  attr_reader :context,
              :turbo_stream_actions

  def game = context.__send__(:game)
  def current_user = context.current_user
  def current_user_token = current_user.token
  def turbo_stream = context.__send__(:turbo_stream)

  def require_game_on
    return unless Game::Status.over?(game)

    raise(GameOverError)
  end

  def require_participant
    return if current_user.participant?

    Games::Current::CreateParticipant.(game:, context:)
    generate_user_nav_turbo_stream_update_action
  end

  def generate_user_nav_turbo_stream_update_action
    nav = CurrentUser::Nav.new(user: current_user)

    turbo_stream_actions <<
      turbo_stream.replace(
        nav.turbo_target,
        method: :morph,
        partial: "current_user/nav",
        locals: { nav: })
  end

  def generate_response
    WarRoom::Responder.(turbo_stream_actions:, context:)
  end

  def activate_participant
    FleetTracker.activate!(current_user_token)
  end

  # :reek:TooManyMethods

  # Games::Current::Board::Cells::DispatchAction::Dispatch is a yielded object
  # the collects / bundles together the Turbo Stream Actions produced by the
  # actual Cell Action being performed by the Controller based on the associated
  # {Game#status}.
  class Dispatch
    include Games::Current::Board::Cells::DispatchBehaviors

    def self.call(...) = new(...).call

    # :reek:DuplicateMethodCall
    def initialize(turbo_stream_actions:, context:)
      @turbo_stream_actions = turbo_stream_actions
      @context = context
      @on_game_start_block = -> {}
    end

    def on_game_start(&block)
      @on_game_start_block = block
    end

    def call
      if game_just_started?
        dispatch_game_start
      elsif game_just_ended?
        dispatch_game_end
      else
        dispatch_game_action
      end
    end

    def <<(turbo_stream_actions)
      self.turbo_stream_actions << turbo_stream_actions
    end

    private

    attr_reader :turbo_stream_actions,
                :context,
                :on_game_start_block

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def game_just_started? = game.just_started?
    def game_just_ended? = game.just_ended?
    def turbo_stream = context.__send__(:turbo_stream)
    def render_to_string(...) = context.render_to_string(...)

    def dispatch_game_start
      turbo_stream_actions << on_game_start_block.call
      generate_game_update_action
    end

    def dispatch_game_action
      generate_game_update_action
    end

    def dispatch_game_end
      generate_just_ended_game_update_action
      enqueue_game_end_update_jobs
    end

    def generate_just_ended_game_update_action
      # Just for the current user session:
      html =
        render_to_string(
          partial: "games/just_ended/container",
          locals: { container: Games::JustEnded::Container.new(game:) })

      target = Games::Current::Container.turbo_frame_name
      turbo_stream_actions.response <<
        turbo_stream.replace(target, html, method: :morph)

      # Just for other user sessions:
      turbo_stream_actions.broadcast << turbo_stream.refresh
    end

    def enqueue_game_end_update_jobs
      Game::Current::BroadcastWarRoomActivityIndicatorUpdateJob.perform_later

      if Game::Type.bestable?(game_type)
        Game::JustEnded::BroadcastNewBestsNotificationJob.perform_later(game)
      end

      Turbo::StreamsChannel.broadcast_refresh_later_to(
        Games::Index.turbo_stream_name)
    end

    def game_type = game.type
  end
end
