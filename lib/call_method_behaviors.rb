# frozen_string_literal: true

# CallMethodBehaviors simplifies object instantiation and #call invocation by
# exposing a single `<Object>.call(...)` interface.
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
    #     def call = "Hello, #{@name}!"
    #   end
    #
    #   Greet.("World") # => "Hello, World!"
    def call(...)
      new(...).call
    end
  end

  def call
    raise(NotImplementedError)
  end
end
