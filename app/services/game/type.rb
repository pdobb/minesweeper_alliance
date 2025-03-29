# frozen_string_literal: true

# Game::Type provides services related to the various {Game#type} values
# (currently: {Game::ALL_TYPES}).
module Game::Type
  BESTABLE_TYPES = [
    Game::BEGINNER_TYPE,
    Game::INTERMEDIATE_TYPE,
    Game::EXPERT_TYPE,
  ].freeze

  def self.validate_bestable(type)
    return if bestable?(type)

    raise(TypeError, "bests not available for Game type #{type.inspect}")
  end

  def self.bestable?(type) = type.in?(BESTABLE_TYPES)
  def self.non_bestable?(type) = !bestable?(type)
end
