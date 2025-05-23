# frozen_string_literal: true

# NullCoordinates represents an empty set of {Coordinates}. It is an
# implementation of the Null Object pattern, which allows us to use it as a
# stand-in for any {Cell} (or otherwise) that expects {Coordinates}, but doesn't
# currently have a sensible X/Y value set.
class NullCoordinates
  def initialize
    freeze
  end

  def x = nil
  def y = nil

  def neighbors = []
  def to_h = {}
  def to_json(*) = "{}"
  def to_s = inspect
  def render = inspect

  def inspect
    "(nil, nil)"
  end
end
