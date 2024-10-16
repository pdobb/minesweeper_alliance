# frozen_string_literal: true

# Games::StatusBehaviors defines common code needed by the Games::* View models
# for showing Game completion status.
module Games::StatusBehaviors
  # :reek:DuplicateMethodCall

  def game_status_mojis
    if game_ended_in_defeat?
      Icon.mine
    elsif game_ended_in_victory?
      "#{Icon.ship}#{Icon.anchor}#{Icon.victory}"
    elsif game_in_progress?
      Icon.ship
    else # Standing By
      Icon.anchor
    end
  end
end
