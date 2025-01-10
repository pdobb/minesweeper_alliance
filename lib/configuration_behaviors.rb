# frozen_string_literal: true

# ConfigurationBehaviors implements a `configure` block API for configuration
# of object/services.
#
# @example Usage
#   class MyObject
#     include ConfigurationBehaviors
#
#     class Configuration
#       attr_accessor :config_option1, :config_option2
#
#       def to_h = { config_option1:, config_option2: }
#     end
#   end
#
#   # config/environment.rb
#
#   MyObject.configure do |config|
#     config.config_option1 = "Value 1"
#     config.config_option2 = "Value 2"
#   end
#
#   MyObject.configuration
#   # => {config_option1: "Value 1", config_option2: "Value 2"}
module ConfigurationBehaviors
  extend ActiveSupport::Concern

  included do
    add_config
  end

  class_methods do
    # :reek:TooManyStatements
    def add_config(name = nil)
      config_method_name = [name, "config"].tap(&:compact!).join("_")
      configure_method_name = ["configure", name].tap(&:compact!).join("_")

      instance_eval(<<~RUBY, __FILE__, __LINE__ + 1)
        # def configuration
        #   <name_>config.to_h
        # end
        def configuration
          #{config_method_name}.to_h
        end

        # def <name_>config
        #   @<name_>config ||= self::<Name>Configuration.new
        # end
        def #{config_method_name}
          @#{config_method_name} ||=
            self::#{name.to_s.classify}Configuration.new
        end

        # def configure<_name>
        #   yield(<name_>config) if block_given?
        #
        #   configuration
        # end
        def #{configure_method_name}
          yield(#{config_method_name}) if block_given?

          configuration
        end
      RUBY
    end
  end
end
