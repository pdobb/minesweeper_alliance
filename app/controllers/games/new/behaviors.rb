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

          store_board_settings(current_game)
        end
      }
  end

  private

  def store_board_settings(current_game)
    return unless (settings = current_game.board_settings).custom?

    layout.store_http_cookie(
      Games::New::Custom::Form::STORAGE_KEY,
      value: settings.to_json)
  end
end
