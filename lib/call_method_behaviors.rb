# frozen_string_literal: true

# CallMethodBehaviors is a mix-in to implement the `call` class/instance method
# pattern used in Service Objects.
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
    def call(...)
      new(...).call
    end
  end

  def call
    raise NotImplementedError
  end
end
