# frozen_string_literal: true

# KeywordWrap simplifies calling
# <target_class>.<builder>(<keyword>: <object>, ...) on all objects within a
# given collection.
#
# For example, `KeywordWrap.new(Thing, as: :object).call(objects)` is roughly
# equivalent to `Array.wrap(objects).flatten.map! { Thing.new(object: it) }`.
#
# @example Straight-up Usage with additional keyword arg
#   class Dog
#     def initialize(name:, owner:)
#       @name = name
#       @owner = owner
#     end
#   end
#
#   KeywordWrap.new(Dog, as: :name).call(%w[Rex Spot], owner: "Bob")
#   # => [#<Dog @name="Rex", @owner="Bob">, #<Dog @name="Spot", @owner="Bob">]
#
# @example Usage via custom `wrap` method + custom builder
#   class Dog
#     def self.wrap(...)
#       KeywordWrap.new(self, as: :name, builder: :build).call(...)
#     end
#
#     def self.build(...) = new(...)
#
#     def initialize(name:, owner:)
#       @name = name
#       @owner = owner
#     end
#   end
#
#   Dog.wrap(%w[Rex Spot], owner: "Bob")
#   # => [#<Dog @name="Rex", @owner="Bob">, #<Dog @name="Spot", @owner="Bob">]
#
# @see Wrap
class KeywordWrap
  def initialize(target_class, as:, builder: :new)
    @target_class = target_class
    @as = as
    @builder = builder
  end

  def call(objects, ...)
    do_wrap(objects) { |object| build(object, ...) }
  end

  private

  attr_reader :target_class,
              :as,
              :builder

  def do_wrap(objects, &)
    Array.wrap(objects).flatten.map!(&)
  end

  def build(object, **)
    target_class.public_send(builder, as => object, **)
  end
end
