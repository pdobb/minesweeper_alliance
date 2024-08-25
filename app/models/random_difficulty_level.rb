# frozen_string_literal: true

# RandomDifficultyLevel quacks like a {DifficultyLevel} just enough for:
#  - "selection" in the UI
#  - {Conversions.DifficultyLevel} to recognize intent and build a random
#    {DifficultyLevel} object
class RandomDifficultyLevel
  NAME = "Random"

  attr_reader :name

  def initialize
    @name = NAME

    freeze
  end
end
