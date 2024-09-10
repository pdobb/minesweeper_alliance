# frozen_string_literal: true

# CoordinatesType is a custom ActiveModel "attributes API" type. It allows for:
# - serializing {Coordinates} objects to JSON
# - casting {Coordinates}, Hash, and String objects to a {Coordinates} object
# - casting unknown types to a {NullCoordinates} object
#
# @example
#   attribute :coordinates, CoordinatesType.new
#
# @see
#  - https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
#  - https://michaeljherold.com/articles/extending-activerecord-with-custom-types
class CoordinatesType < ActiveModel::Type::Value
  # Can be used to register this type with the ActiveModel::Type registry.
  def type
    :coordinates
  end

  # :reek:ControlParameter
  # :reek:UtilityFunction

  # Casts the given value from a Ruby type to the type needed by the database.
  def serialize(value)
    ActiveSupport::JSON.encode(value || NullCoordinates.new)
  end

  private

  # Casts a value from user input (e.g. from a setter) to our {Coordinates} (or
  # {NullCoordinates}) type. Called by public method
  # ActiveModel::Type::Value#cast, unless the given value is nil.
  def cast_value(value)
    case value
    when Coordinates
      value
    when Hash
      Coordinates.new(**value.symbolize_keys)
    when String
      cast_string_value(value)
    else
      NullCoordinates.new
    end
  end

  def cast_string_value(value)
    hash = ActiveSupport::JSON.decode(value)
    Coordinates.new(**hash.symbolize_keys)
  rescue
    NullCoordinates.new
  end
end
