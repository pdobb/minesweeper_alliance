# frozen_string_literal: true

# Games::New::Behaviors defines common controller code for {Game} creation.
module Games::New::Behaviors
  def find_or_create_current_game(settings:)
    Game.
      find_or_create_current(settings:, user: current_user).
      tap { |current_game| OnCreate.(current_game:, context: layout) }
  end

  # Games::New::Behaviors::OnCreate
  class OnCreate
    TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS = 0.25.seconds

    include CallMethodBehaviors

    def initialize(current_game:, context:)
      @current_game = current_game
      @context = context
    end

    def call
      return unless just_created?

      FleetTracker.reset
      WarRoomChannel.broadcast_refresh
      broadcast_new_game_notification
      store_board_settings
    end

    private

    attr_reader :current_game,
                :context

    def just_created? = current_game.just_created?

    def broadcast_new_game_notification(
          wait: TURBO_STREAM_DISCONNECT_AFFORDANCE_IN_SECONDS)
      Games::BroadcastCreateNotificationJob.set(wait:).perform_later
    end

    def store_board_settings
      return unless custom_settings?

      context.store_http_cookie(
        Games::New::Custom::Form::STORAGE_KEY,
        value: settings.to_json)
    end

    def settings = @settings ||= current_game.board_settings
    def custom_settings? = settings.custom?
  end
end
