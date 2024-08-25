# frozen_string_literal: true

# Games::StatusBehaviors defines common code needed by the Games::* View models
# for showing Game completion status.
module Games::StatusBehaviors
  def game_status_mojis
    if game_ended_in_victory?
      Icon.celebratory_victory
    else # ended_in_defeat?
      Icon.humiliating_defeat
    end
  end
end
