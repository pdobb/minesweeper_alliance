# frozen_string_literal: true

# Games::New::Behaviors defines common controller code for {Game} creation.
module Games::New::Behaviors
  # :reek:FeatureEnvy

  def find_or_create_current_game(settings:)
    Game.
      find_or_create_current(settings:, user: current_user).
      tap { |current_game|
        if current_game.just_created?
          DutyRoster.clear
          WarRoomChannel.broadcast_refresh
          notify_other_players_of_new_current_game

          store_board_settings(current_game)
        end
      }
  end

  private

  def notify_other_players_of_new_current_game
    Turbo::StreamsChannel.broadcast_update_to(
      Games::JustEnded::Container.turbo_stream_name,
      target: :new_game_notification_container,
      partial: "layouts/flash/notifications",
      locals: { notifications: new_current_game_notification })
  end

  def new_current_game_notification
    Application::Flash::Notification.new(
      type: :info,
      content: {
        text: t("flash.new_current_game_html"),
        timeout: false,
      })
  end

  def store_board_settings(current_game)
    return unless (settings = current_game.board_settings).custom?

    layout.store_http_cookie(
      Games::New::Custom::Form::STORAGE_KEY,
      value: settings.to_json)
  end
end
