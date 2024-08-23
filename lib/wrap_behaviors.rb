# frozen_string_literal: true

require "active_support/concern"

# WrapBehaviors is a mix-in of `wrap` methods, for wrapping all objects within
# the given collection.
module WrapBehaviors
  extend ActiveSupport::Concern

  class_methods do
    # @example
    #   class Dog
    #     include WrapBehaviors
    #
    #     def initialize(name)
    #       @name = name
    #     end
    #   end
    #
    #   Dog.wrap(["Spot", "Max"]) # =>
    #     [#<Dog @name="Spot">, #<Dog @name="Max">]
    def wrap(objects, *args)
      Array.wrap(objects).map { |object|
        new(object, *args)
      }
    end
  end
end
