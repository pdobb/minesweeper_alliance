# frozen_string_literal: true

require "forwardable"

# CoordinatesSet represents a Set of {Coordinates} objects (X/Y pairs).
class CoordinatesSet
  extend Forwardable

  include Enumerable
  include Comparable

  def_delegators(:set, *%i[
    <<
    add
    delete
    each
    include?
    size
    to_a
  ])

  def initialize(coordinates_set = [])
    @set =
      Array.wrap(coordinates_set).to_set { |coordinates|
        Conversions.Coordinates(coordinates)
      }
    freeze
  end

  def to_set = self

  def <=>(other)
    other = Conversions.CoordinatesSet(other)
    to_a <=> other.to_a
  end

  def toggle(coordinates)
    if include?(coordinates)
      delete(coordinates)
    else
      add(coordinates)
    end

    self
  end

  private

  attr_reader :set

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      { self => set.map(&:inspect) }
    end

    private

    def inspect_info
      "x#{size}"
    end
  end
end
