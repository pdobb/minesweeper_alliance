# frozen_string_literal: true

# WrapMethodBehaviors is a mix-in of `wrap` methods, for wrapping all objects
# within the given collection.
module WrapMethodBehaviors
  extend ActiveSupport::Concern

  class_methods do
    # @example
    #   class Dog
    #     include WrapMethodBehaviors
    #
    #     def initialize(name)
    #       @name = name
    #     end
    #   end
    #
    #   Dog.wrap(["Spot", "Max"]) # =>
    #     [#<Dog @name="Spot">, #<Dog @name="Max">]
    def wrap(objects, ...)
      Array.wrap(objects).map { |object|
        new(object, ...)
      }
    end

    # :reek:LongParameterList

    # @example
    #   class Dog
    #     include WrapMethodBehaviors
    #
    #     def initialize(name)
    #       @name = name
    #     end
    #   end
    #
    #   Dog.wrap_upto(["Spot", "Max"], limit: 3) # =>
    #     [#<Dog @name="Spot">, #<Dog @name="Max">, nil]
    #
    #   Dog.wrap_upto(["Spot", "Max"], limit: 3, fill: NullDog.new) # =>
    #     [#<Dog @name="Spot">, #<Dog @name="Max">, #<NullDog...>]
    def wrap_upto(objects, *, limit:, fill: nil, **)
      Array.new(limit) { |index|
        (object = objects[index]) ? new(object, *, **) : fill
      }
    end
  end
end
