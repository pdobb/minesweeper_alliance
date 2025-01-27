# frozen_string_literal: true

# Game::Current is responsible for look-up/creation of the "Current {Game}"
# record. Only one "Current {Game}" can exist at a time.
#
# The "Current Game" is the one with a "Game On" status:
# - Standing By
# - Sweep in Progress
#
# NOTE: While finding the current {Game} doesn't require a {User} record,
# creation does. And we can't be sure in advance if an existing record will be
# found or if a new record will need to be created. We rely on the database to
# determine as it can change from sub-second to sub-second!
class Game::Current
  include CallMethodBehaviors

  def self.find = Game.for_game_on_statuses.take

  def initialize(settings:, user:, &after_create_block)
    @settings = settings
    @user = user
    @after_create_block = after_create_block
  end

  def call
    find || create
  rescue ActiveRecord::RecordNotUnique
    # Handle race conditions on Game creation.
    retry
  end

  private

  attr_reader :settings,
              :user,
              :after_create_block

  def find = self.class.find

  def create
    do_create.tap { |new_game|
      AfterCreate.(game: new_game, &after_create_block)
    }
  end

  def do_create
    Game.create_for(settings:) { |new_game|
      GameCreateTransaction.create_between(user:, game: new_game)
    }
  end

  # Game::Current::AfterCreate executes follow-up tasks after a new "Current
  # {Game}" is created. Accepts a block for any one-off tasks.
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

      block&.call
    end

    private

    attr_reader :game,
                :block

    def broadcast_fleet_mustering_notification(
          wait: TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS)
      Games::Current::BroadcastFleetMusteringNotificationJob.set(wait:).
        perform_later
    end
  end
end
