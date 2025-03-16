# frozen_string_literal: true

# Game::Current::Find handles finding the "Current {Game}".
module Game::Current::Find
  def self.call
    Game.for_current_or_recently_ended.last
  end

  # Direct access of the "Current {Game}" (doesn't consider recently ended
  # {Game}s).
  #
  # @return [NilClass] If no Current Game is found.
  def self.take(base_arel: Game)
    base_arel.for_game_on_statuses.take
  end

  # Direct access of the "Current {Game}" (doesn't consider recently ended
  # {Game}s).
  #
  # @raise [ActiveRecord::RecordNotFound] If no Current Game is found.
  def self.take!(base_arel: Game)
    base_arel.for_game_on_statuses.take!
  end
end
