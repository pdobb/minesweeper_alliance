# frozen_string_literal: true

# Game::Current::Find handles finding the "Current {Game}".
module Game::Current::Find
  def self.call = Game.for_game_on_statuses.take
end
