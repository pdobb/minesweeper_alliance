# frozen_string_literal: true

# Conversions is a mix-in of Conversion Functions. i.e. Functions that convert
# a given value to a desired (custom) type. Much the same as Ruby's Array,
# String, Integer, etc classes all have like-named Conversion Functions.
module Conversions
  # :reek:UncommunicateMethodName

  def self.DifficultyLevel(value) # rubocop:disable Naming/MethodName
    case value
    when DifficultyLevel
      value
    when ->(val) { val.respond_to?(:to_difficulty_level) }
      value.to_difficulty_level
    else
      DifficultyLevel.new(value)
    end
  end
end
