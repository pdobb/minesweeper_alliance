# frozen_string_literal: true

# Games::StatusBehaviors defines common code needed by the Games::* View models
# for showing Game completion status.
module Games::StatusBehaviors
  # :reek:DuplicateMethodCall

  def game_status_mojis
    if game_ended_in_defeat?
      Emoji.mine
    elsif game_ended_in_victory?
      "#{Emoji.ship}#{Emoji.victory}"
    elsif game_in_progress?
      Emoji.ship
    else # Standing By
      Emoji.anchor
    end
  end
end
