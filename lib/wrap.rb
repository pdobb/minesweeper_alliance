# frozen_string_literal: true

# Wrap simplifies calling <target_class>.<builder>(<object>, ...) on all
# objects within a given collection.
#
# For example, `Wrap.new(Thing).call(objects)` is roughly equivalent to
# `Array.wrap(objects).flatten.map! { Thing.new(it) }`.
#
# @example Straight-up Usage with additional keyword arg
#   class Dog
#     def initialize(name, owner:)
#       @name = name
#       @owner = owner
#     end
#   end
#
#   Wrap.new(Dog).call(%w[Rex Spot], owner: "Bob")
#   # => [#<Dog @name="Rex", @owner="Bob">, #<Dog @name="Spot", @owner="Bob">]
#
# @example Usage via custom `wrap` method + custom builder
#   class Dog
#     def self.wrap(...)
#       Wrap.new(self, builder: :build).call(...)
#     end
#
#     def self.build(...) = new(...)
#
#     def initialize(name, owner:)
#       @name = name
#       @owner = owner
#     end
#   end
#
#   Dog.wrap(%w[Rex Spot], owner: "Bob")
#   # => [#<Dog @name="Rex", @owner="Bob">, #<Dog @name="Spot", @owner="Bob">]
#
# @see KeywordWrap
class Wrap
  def initialize(target_class, builder: :new)
    @target_class = target_class
    @builder = builder
  end

  def call(objects, ...)
    do_wrap(objects) { |object| build(object, ...) }
  end

  private

  attr_reader :target_class,
              :builder

  def do_wrap(objects, &)
    Array.wrap(objects).flatten.map!(&)
  end

  def build(...)
    target_class.public_send(builder, ...)
  end
end
