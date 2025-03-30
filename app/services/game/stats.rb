# frozen_string_literal: true

# Game::Stats provides services related to {Game} statistics.
module Game::Stats
  def self.duration(game)
    game.ended_at - game.started_at if game.over?
  end

  def self.engagement_time_range(game)
    game.started_at..(game.ended_at if game.over?)
  end
end
