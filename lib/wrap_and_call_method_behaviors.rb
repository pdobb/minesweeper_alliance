# frozen_string_literal: true

# WrapAndCallMethodBehaviors combines {WrapMethodBehaviors} and
# {CallMethodBehaviors} to simplify the compound process of:
# 1. Wrapping collections of objects, and then immediately
# 2. Calling `call` on each of them
# ... all based on a single class method.
module WrapAndCallMethodBehaviors
  extend ActiveSupport::Concern

  include WrapMethodBehaviors
  include CallMethodBehaviors

  class_methods do
    # @example
    #   class Dog
    #     include WrapAndCallMethodBehaviors
    #
    #     def initialize(name)
    #       @name = name
    #     end
    #
    #     def call = "See #{@name} run."
    #   end
    #
    #   Dog.wrap_and_call(["Spot", "Max"])
    #   # => ["See Spot run.", "See Max run."]
    #
    #   Dog.wrap_and_call(["Spot", ["Max"]])
    #   # => ["See Spot run.", "See Max run."]
    def wrap_and_call(objects, ...)
      wrap(objects, ...).map(&:call)
    end
  end
end
