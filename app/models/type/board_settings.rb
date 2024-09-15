# frozen_string_literal: true

# Type::BoardSettings is a custom ActiveModel "attributes API" type. It allows
# for:
# - serializing {Board::Settings} objects to JSON
# - casting {Board::Settings} and Hash objects to a {Board::Settings} object
# - casting unknown types to a {Board::NullSettings} object
#
# @example
#   attribute :settings, Type::BoardSettings.new
#
# @see
#  - https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
#  - https://michaeljherold.com/articles/extending-activerecord-with-custom-types
class Type::BoardSettings < ActiveModel::Type::Value
  # Can be used to register this type with the ActiveModel::Type registry,
  # though we opt out to be more explicit/transparent.
  def type
    :board_settings
  end

  # :reek:ControlParameter
  # :reek:UtilityFunction

  # Casts the given value from a Ruby type to the type needed by the database.
  def serialize(value)
    ActiveSupport::JSON.encode(value || Board::NullSettings.new)
  end

  private

  # Casts a value from user input (e.g. from a setter) to our {Board::Settings}
  # (or {Board::NullSettings}) type. Called by public method
  # ActiveModel::Type::Value#cast, unless the given value is nil.
  def cast_value(value)
    case value
    when Board::Settings
      value
    when Hash
      Board::Settings.new(**value.symbolize_keys)
    when String
      cast_string_value(value)
    else
      Board::NullSettings.new
    end
  end

  def cast_string_value(value)
    hash = ActiveSupport::JSON.decode(value)
    Board::Settings.new(**hash.symbolize_keys)
  rescue
    Board::NullSettings.new
  end
end
