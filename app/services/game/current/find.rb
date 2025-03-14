# frozen_string_literal: true

# Game::Current::Find handles finding the "Current {Game}".
module Game::Current::Find
  def self.call
    Game.for_current_or_recently_ended.last
  end
end
