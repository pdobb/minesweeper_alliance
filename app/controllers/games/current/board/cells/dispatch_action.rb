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
  def initialize(context:)
    @context = context
    @turbo_stream_actions = FlatArray.new

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
    WarRoom::Responder.new(context:).(turbo_stream_actions:)
  end

  def activate_participant
    FleetTracker.activate!(current_user_token)
  end

  # Games::Current::Board::Cells::DispatchAction::Dispatch is a yielded object
  # the collects / bundles together the Turbo Stream Actions produced by the
  # actual Cell Action being performed by the Controller based on the associated
  # {Game#status}.
  class Dispatch
    include CallMethodBehaviors

    # :reek:DuplicateMethodCall
    def initialize(turbo_stream_actions:, context:)
      @turbo_stream_actions = turbo_stream_actions
      @context = context
      @on_game_start_block = -> {}
      @on_game_end_block = -> {}
    end

    def on_game_start(&block)
      @on_game_start_block = block
    end

    def on_game_end(&block)
      @on_game_end_block = block
    end

    def call(result)
      if game_just_started?
        dispatch_game_start(result:)
      elsif game_just_ended?
        dispatch_game_end
      else
        capture(result:)
      end
    end

    def <<(turbo_stream_actions)
      self.turbo_stream_actions << turbo_stream_actions
    end

    private

    attr_reader :turbo_stream_actions,
                :context,
                :on_game_start_block,
                :on_game_end_block

    def game = context.__send__(:game)
    def game_just_started? = game.just_started?
    def game_just_ended? = game.just_ended?
    def turbo_stream = context.__send__(:turbo_stream)
    def render_to_string(...) = context.render_to_string(...)

    def dispatch_game_start(result:)
      turbo_stream_actions << on_game_start_block.call
      capture(result:)
    end

    def dispatch_game_end
      turbo_stream_actions << on_game_end_block.call
      generate_just_ended_game_update_action
      enqueue_game_end_update_jobs
    end

    def generate_just_ended_game_update_action
      container = Games::JustEnded::Container.new(game:)
      target = container.turbo_frame_name
      html =
        render_to_string(
          partial: "games/just_ended/container", locals: { container: })
      # Can't use `:morph` here or our stimulus controller
      # (new_game_content_controller.js) will fail to remove the "Custom" button
      # for non-signers on the 2nd rendering--as a result of the broadcast.

      turbo_stream_actions << turbo_stream.replace(target, html:)
    end

    def enqueue_game_end_update_jobs
      Game::Current::BroadcastWarRoomActivityIndicatorUpdateJob.perform_later

      if game.bestable_type?
        Game::JustEnded::BroadcastNewBestsNotificationJob.perform_later(game)
      end

      Turbo::StreamsChannel.broadcast_refresh_later_to(
        Games::Index.turbo_stream_name)
    end

    def capture(result:)
      turbo_stream_actions <<
        Cell::TurboStream::Morph.wrap_and_call(
          result.updated_cells,
          turbo_stream:)
    end
  end
end
