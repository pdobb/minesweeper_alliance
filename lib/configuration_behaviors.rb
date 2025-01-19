# frozen_string_literal: true

# ConfigurationBehaviors implements a simple `configure do |config|` block-style
# API for configuration of objects/services.
#
# @example Usage
#   class MyObject
#     include ConfigurationBehaviors
#
#     class Configuration
#       attr_accessor :configurable_option1, :configurable_option2
#     end
#   end
#
#   # Set the configuration (in e.g. config/environment.rb):
#   MyObject.configure do |config|
#     config.configurable_option1 = "Value 1"
#     config.configurable_option2 = "Value 2"
#   end
#
#   # Use it:
#   MyObject.configuration.configurable_option1 # => "Value 1"
module ConfigurationBehaviors
  extend ActiveSupport::Concern

  class_methods do
    def configure
      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= self::Configuration.new
    end
  end
end
