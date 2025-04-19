# frozen_string_literal: true

# Conversions is a mix-in of Conversion Functions. i.e. Functions that convert
# a given value to a desired (custom) type. Much the same as Ruby's Array,
# String, Integer, etc classes all have like-named Conversion Functions.
module Conversions
  # :reek:UncommunicativeMethodName

  # rubocop:disable Naming/MethodName, Metrics/MethodLength
  def self.Coordinates(value)
    case value
    when Coordinates
      value
    when Hash
      hash = value.symbolize_keys
      Coordinates.new(hash.fetch(:x), hash.fetch(:y))
    when Array
      Coordinates[*value]
    else
      raise(
        TypeError,
        "Can't convert unexpected type to Coordinates, got #{value.class}")
    end
  end
  # rubocop:enable Naming/MethodName, Metrics/MethodLength

  # :reek:UncommunicativeMethodName

  def self.CoordinatesSet(value) # rubocop:disable Naming/MethodName
    case value
    when CoordinatesSet
      value
    when Array,
         Coordinates
      CoordinatesSet.new(value)
    else
      raise(
        TypeError,
        "Can't convert unexpected type to CoordinatesSet, got #{value.class}")
    end
  end
end
