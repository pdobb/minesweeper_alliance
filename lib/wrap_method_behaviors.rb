# frozen_string_literal: true

# WrapMethodBehaviors simplifies wrapping all objects within a given collection.
# i.e. instantiating a new <self> (Class), for each item in the given `objects`
# Array. Use the bang (!) version of a "wrap" method to immediately `call` the
# wrapped/instantiated objects as well.
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
    #   Dog.wrap(["Spot", "Max"])
    #   # => [#<Dog @name="Spot">, #<Dog @name="Max">]
    #
    #   Dog.wrap(["Spot", ["Max"]])
    #   # => [#<Dog @name="Spot">, #<Dog @name="Max">]
    def wrap(objects, ...)
      Array.wrap(objects).flatten.map! { |object|
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
    #   Dog.wrap_upto(["Spot", "Max"], limit: 1)
    #   # => [#<Dog @name="Spot">]
    #
    #   Dog.wrap_upto(["Spot", "Max"], limit: 3)
    #   # => [#<Dog @name="Spot">, #<Dog @name="Max">, nil]
    #
    #   Dog.wrap_upto(["Spot", "Max"], limit: 3, fill: NullDog.new)
    #   # => [#<Dog @name="Spot">, #<Dog @name="Max">, #<NullDog...>]
    def wrap_upto(objects, *, limit:, fill: nil, **)
      flat_objects = Array.wrap(objects).flatten
      Array.new(limit) { |index|
        (object = flat_objects[index]) ? new(object, *, **) : fill
      }
    end
  end
end
