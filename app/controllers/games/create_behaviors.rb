# frozen_string_literal: true

# Games::CreateBehaviors defines common code needed by the Games::* View models
# for showing {Game}-specific info.
module Games::CreateBehaviors
  # :reek:UtilityFunction

  def find_or_create_game(difficulty_level:)
    current_game = Game.find_or_create_current(difficulty_level:)
    return unless current_game.just_created?

    DutyRoster.clear
    current_game.broadcast_refresh_to(:current_game)
  end
end
