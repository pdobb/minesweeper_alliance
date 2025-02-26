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
    :[], :[]=, :each, :first, :join, :last, :size, :sort, :sort!,
    :to_a, :to_ary, :uniq!)

  def self.[](*) = new(*)

  def initialize(*items)
    @array = items
  end

  def <<(item) = add(item)
  def push(item) = add(item)
  def concat(item) = add(item)

  private

  attr_reader :array

  def add(item)
    array.concat(Array.wrap(item).flatten)
  end
end
