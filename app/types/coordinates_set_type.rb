# frozen_string_literal: true

# CoordinatesSetType is a custom ActiveModel "attributes API" type. It allows
# for:
# - Serializing Arrays of {Coordinates} objects to JSON
# - Casting Arrays of {Coordinates}, Hash, and String objects to a
#   {CoordinatesSet} object
# - Casting unknown types to an empty Array object
#
# @example
#   attribute :coordinates_set, CoordinatesSetType.new
#
# @see
#  - https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
#  - https://michaeljherold.com/articles/extending-activerecord-with-custom-types
class CoordinatesSetType < ActiveModel::Type::Value
  # Can be used to register this type with the ActiveModel::Type registry,
  # though we opt out to be more explicit/transparent.
  def type
    :coordinates_set
  end

  # :reek:ControlParameter
  # :reek:UtilityFunction

  # Casts the given value from a Ruby type to the type needed by the database.
  def serialize(value)
    ActiveSupport::JSON.encode(value || [])
  end

  private

  # Casts a value from user input (e.g. from a setter) to our {CoordinatesSet}
  # type. Called by public method ActiveModel::Type::Value#cast, unless the
  # given value is nil.
  def cast_value(value)
    case value
    when CoordinatesSet
      value
    when Array
      CoordinatesSet.new(parse(value))
    when String
      cast_string_value(value)
    else
      []
    end
  end

  def cast_string_value(value)
    hashes = ActiveSupport::JSON.decode(value)
    CoordinatesSet.new(parse(hashes))
  rescue
    []
  end

  def parse(value)
    value.map { |a_value| Conversions.Coordinates(a_value) }
  end
end
