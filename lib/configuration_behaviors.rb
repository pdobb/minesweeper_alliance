# frozen_string_literal: true

# ConfigurationBehaviors provides a simple API for configuration of
# objects/services using the familiar `configure do |config|` block style.
#
# @example Usage
#   class MyObject
#     include ConfigurationBehaviors
#
#     Configuration = Struct.new(:option1, :option2)
#   end
#
#   # Set the configuration (in e.g. config/environment.rb):
#   MyObject.configure do |config|
#     config.option1 = "Value 1"
#     config.option2 = "Value 2"
#   end
#   # => #<struct MyObject::Configuration option1="Value 1", option2="Value 2">
#
#   MyObject.configuration.option1 # => "Value 1"
#   MyObject.configuration.option2 # => "Value 2"
#   MyObject.configuration.to_h    # => {option1: "Value 1", option2: "Value 2"}
module ConfigurationBehaviors
  extend ActiveSupport::Concern

  class_methods do
    def configure
      yield(configuration) if block_given?
      configuration
    end

    def configuration
      @configuration ||= self::Configuration.new
    end
  end
end
