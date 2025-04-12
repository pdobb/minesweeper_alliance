# frozen_string_literal: true

require "forwardable"

# CompactArray is an Array-like object that automatically rejects `nil` values.
# It otherwise acts like an Array, as needed.
#
# @example
#   CompactArray.new.tap { it << nil }.to_a   # => []
#   CompactArray.new.tap { it << 1 }.to_a     # => [1]
#   CompactArray.new.tap { it << false }.to_a # => [false]
class CompactArray
  extend Forwardable

  include Enumerable

  def_delegators(
    :array,
    *%i[
      []
      []=
      concat
      each
      first
      include?
      join
      last
      size
      sort
      sort!
      to_a
      to_ary
      uniq!
    ])

  def self.[](*) = new(*)

  def initialize(*items)
    @array = items.compact
  end

  def <<(item) = add(item)
  def push(*items) = add(items)

  def sort = self.class.new(*array.sort)

  private

  attr_reader :array

  def add(item)
    array.concat(Array.wrap(item).compact)
  end
end
