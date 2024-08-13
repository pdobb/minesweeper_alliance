# frozen_string_literal: true

# CoordinatesType is a custom ActiveModel `attributes` API type. It allows for:
# - casting {Coordinates}, Hash, and String objects to {Coordinates} objects
# - serializing {Coordinates} objects to JSON
#
# @example
#   attribute :coordinates, CoordinatesType.new
#
# @see https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
class CoordinatesType < ActiveModel::Type::Value
  def type
    :jsonb
  end

  def cast_value(value)
    case value
    when Coordinates
      value
    when Hash
      Coordinates.new(**value.symbolize_keys)
    when String
      begin
        hash = ActiveSupport::JSON.decode(value)
        Coordinates.new(**hash.symbolize_keys)
      rescue
        NullCoordinates.new
      end
    when NilClass
      NullCoordinates.new
    end
  end

  def serialize(value)
    case value
    when Hash,
         Coordinates
      ActiveSupport::JSON.encode(value)
    when NilClass
      ActiveSupport::JSON.encode(NullCoordinates.new)
    else
      super
    end
  end
end
