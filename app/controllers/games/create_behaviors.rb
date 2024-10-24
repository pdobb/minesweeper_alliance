# frozen_string_literal: true

# Games::CreateBehaviors defines common code needed by the Games::* View models
# for showing {Game}-specific info.
module Games::CreateBehaviors
  # :reek:FeatureEnvy

  def find_or_create_game(settings:)
    Game.find_or_create_current(settings:).tap { |current_game|
      if current_game.just_created?
        DutyRoster.clear
        current_game.broadcast_refresh_to(:current_game)

        store_board_settings(current_game)
      end
    }
  end

  private

  def store_board_settings(current_game)
    return unless (settings = current_game.board_settings).custom?

    layout.store_http_cookie(
      Games::Customs::New::Form::STORAGE_KEY,
      value: settings.to_json)
  end
end
