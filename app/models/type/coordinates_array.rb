# frozen_string_literal: true

# Type::CoordinatesArray is a custom ActiveModel "attributes API" type. It
# allows for:
# - serializing Arrays of {Coordinates} objects to JSON
# - casting Arrays of {Coordinates}, Hash, and String objects to a
#   {CoordinatesArray} object
# - casting unknown types to an empty Array object
#
# @example
#   attribute :coordinates_array, Type::CoordinatesArray.new
#
# @see
#  - https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
#  - https://michaeljherold.com/articles/extending-activerecord-with-custom-types
class Type::CoordinatesArray < ActiveModel::Type::Value
  # Can be used to register this type with the ActiveModel::Type registry,
  # though we opt out to be more explicit/transparent.
  def type
    :coordinates_array
  end

  # :reek:ControlParameter
  # :reek:UtilityFunction

  # Casts the given value from a Ruby type to the type needed by the database.
  def serialize(value)
    ActiveSupport::JSON.encode(value || [])
  end

  private

  # Casts a value from user input (e.g. from a setter) to our {CoordinatesArray}
  # type. Called by public method ActiveModel::Type::Value#cast, unless the
  # given value is nil.
  def cast_value(value)
    case value
    when CoordinatesArray
      value
    when Array
      CoordinatesArray.new(parse(value))
    when String
      cast_string_value(value)
    else
      []
    end
  end

  def cast_string_value(value)
    hashes = ActiveSupport::JSON.decode(value)
    CoordinatesArray.new(parse(hashes))
  rescue
    []
  end

  def parse(value)
    value.map { |a_value| Conversions.Coordinates(a_value) }
  end
end
