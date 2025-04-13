# frozen_string_literal: true

# Game::Status provides services related to the various {Game} statuses.
module Game::Status
  def self.on?(game)
    game.status?([Game.status_standing_by, Game.status_sweep_in_progress])
  end

  def self.over?(game)
    !on?(game)
  end
end
