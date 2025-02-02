# frozen_string_literal: true

require "forwardable"

# FlatArray is an Array that presents a friendly interface for ensuring single
# or multiple-object pushes are always nicely concatenated on, instead of
# creating an Array of Arrays. It should otherwise act like an Array, as needed.
class FlatArray
  extend Forwardable

  include Enumerable

  def_delegators(
    :array,
    :[], :[]=, :concat, :each, :first, :join, :last, :size, :sort, :sort!,
    :to_a, :to_ary, :uniq!)

  def self.[](*) = new(*)

  def initialize(*items)
    @array = items
  end

  def <<(item) = add(item)
  def push(item) = add(item)

  private

  attr_reader :array

  def add(item)
    concat(Array.wrap(item))
  end
end
