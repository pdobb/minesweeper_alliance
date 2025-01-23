# frozen_string_literal: true

# Games::New::Behaviors defines common controller code for {Game} creation.
module Games::New::Behaviors
  def find_or_create_current_game(settings:)
    Game.
      find_or_create_current(settings:, user: current_user).
      tap { |game| OnCreate.(game:, context: layout) if game.just_created? }
  end

  # Games::New::Behaviors::OnCreate
  class OnCreate
    TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS = 0.25.seconds

    include CallMethodBehaviors

    def initialize(game:, context:)
      @game = game
      @context = context
    end

    def call
      return unless just_created?

      FleetTracker.reset
      WarRoomChannel.broadcast_refresh
      broadcast_fleet_mustering_notification
      store_board_settings
    end

    private

    attr_reader :game,
                :context

    def just_created? = game.just_created?

    def broadcast_fleet_mustering_notification(
          wait: TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS)
      Games::Current::BroadcastFleetMusteringNotificationJob.set(wait:).
        perform_later
    end

    def store_board_settings
      return unless custom_settings?

      context.store_http_cookie(
        Games::New::Custom::Form::STORAGE_KEY,
        value: settings.to_json)
    end

    def settings = @settings ||= game.board_settings
    def custom_settings? = settings.custom?
  end
end
