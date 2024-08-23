# frozen_string_literal: true

require "active_support/concern"

# CallMethodBehaviors is a mix-in to implement the `call` class/instance method
# pattern used in service objects.
module CallMethodBehaviors
  extend ActiveSupport::Concern

  class_methods do
    # @example
    #   class Greet
    #     include CallMethodBehaviors
    #
    #     def initialize(name)
    #       @name = name
    #     end
    #
    #     def call
    #       "Hello, #{@name}!"
    #     end
    #   end
    #
    #   Greet.("World") # => "Hello, World!"
    def call(*args, &block)
      new(*args, &block).call
    end
  end

  def call
    on_call
  end

  def on_call
    raise NotImplementedError
  end
end