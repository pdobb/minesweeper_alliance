# frozen_string_literal: true

# Game::Current::Create handles new "Current {Game}" creation.
#
# If the given {User} (passed in via the given {#context}) is actually a {Guest}
# (i.e. {User#past_participant?} == false), then BeforeCreate will handle
# creation of a new {User} record to replace the {Guest} role.
#
# Next, Game::Current::Create will, itself, handle creation of a
# {GameCreateTransaction} and an active {ParticipantTransaction} between the
# {User} and {Game}.
#
# AfterCreate is then responsible for all new-{Game}-creation follow-up tasks
# like resetting the {FleetTracker} and broadcasting notifications to other
# players.
class Game::Current::Create
  include CallMethodBehaviors

  def initialize(settings:, context:, &after_create_block)
    @settings = settings
    @context = context
    @after_create_block = after_create_block
  end

  def call
    BeforeCreate.(context:)
    new_game = do_create
    AfterCreate.(game: new_game, &after_create_block)
  end

  private

  attr_reader :settings,
              :context,
              :after_create_block

  def user = User::Current::Find.(context: layout)
  def layout = context.layout

  def do_create
    Game.create_for(settings:) { |new_game|
      GameCreateTransaction.create_between(user:, game: new_game)
      ParticipantTransaction.create_active_between(user:, game: new_game)
      FleetTracker.add!(user.token)
    }
  end

  # Game::Current::Create::BeforeCreate executes preparatory tasks before a new
  # "Current {Game}" is created.
  class BeforeCreate
    include CallMethodBehaviors

    def initialize(context:)
      @context = context
    end

    def call
      return if past_participant?

      context.current_user_will_change
      User::Current::Create.(context:)
    end

    private

    attr_reader :context

    def user = context.user
    def past_participant? = user.participant?
  end

  # Game::Current::Create::AfterCreate executes follow-up tasks after a new
  # "Current {Game}" is created. Accepts/calls a block for any one-off tasks.
  class AfterCreate
    TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS = 0.25.seconds

    include CallMethodBehaviors

    def initialize(game:, &block)
      @game = game
      @block = block
    end

    def call
      FleetTracker.reset

      WarRoomChannel.broadcast_refresh
      broadcast_fleet_mustering_notification
      broadcast_war_room_activity_indicator_update_job

      block&.call
    end

    private

    attr_reader :game,
                :block

    def broadcast_fleet_mustering_notification(
          wait: TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS)
      Game::Current::BroadcastFleetMusteringNotificationJob.set(wait:).
        perform_later
    end

    def broadcast_war_room_activity_indicator_update_job
      Game::Current::BroadcastWarRoomActivityIndicatorUpdateJob.perform_later
    end
  end
end
