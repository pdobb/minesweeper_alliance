require "active_support/concern"

module WrapBehaviors
  extend ActiveSupport::Concern

  class_methods do
    # @example
    #   class Hello
    #     include WrapBehaviors
    #
    #     def initialize(name)
    #       @name = name
    #     end
    #
    #     def call
    #       "Hi, my name is #{@name}!"
    #     end
    #   end
    #
    #   Hello.wrap(["Joe", "Bob"]) # =>
    #     [#<Hello:xxx @name="Joe">, #<Hello:xxx @name="Bob">]
    #   Hello.wrap(["Joe", "Bob"]).map(&:call) # =>
    #     ["Hi, my name is Joe!", "Hi, my name is Bob!"]
    def wrap(objects, *args)
      Array.wrap(objects).map { |object|
        new(object, *args)
      }
    end
  end
end
