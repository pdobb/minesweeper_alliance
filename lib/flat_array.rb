# frozen_string_literal: true

require "forwardable"

# FlatArray is an Array-like object that automatically concatenates and/or
# flattens whatever is added to it. It otherwise acts like an Array, as needed.
#
# @example
#   FlatArray.new.tap { it << [1, [2, [3]]] }.to_a      # => [1, 2, 3]
#   FlatArray.new.tap { it.push([1, [2, [3]]]) }.to_a   # => [1, 2, 3]
#   FlatArray.new.tap { it.concat([1, [2, [3]]]) }.to_a # => [1, 2, 3]
class FlatArray
  extend Forwardable

  include Enumerable

  def_delegators(
    :array,
    *%i[
      -
      |
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
    @array = items.flatten
  end

  def <<(item) = add(item)
  def push(*items) = add(items)
  def concat(items) = add(items)

  def sort = self.class.new(array.sort)

  private

  attr_reader :array

  def add(items)
    array.concat(Array.wrap(items).flatten)
  end
end
