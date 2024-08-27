# frozen_string_literal: true

# Games::StatusBehaviors defines common code needed by the Games::* View models
# for showing Game completion status.
module Games::StatusBehaviors
  def game_status_mojis
    if game_ended_in_victory?
      Icon.celebratory_victory
    elsif game_ended_in_defeat?
      Icon.humiliating_defeat
    elsif game_in_progress?
      Icon.ship
    end
  end
end
