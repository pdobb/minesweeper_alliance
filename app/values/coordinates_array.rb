# frozen_string_literal: true

require "forwardable"

# CoordinatesArray represents an Array of {Coordinates} objects (X/Y pairs).
class CoordinatesArray
  extend Forwardable

  include Enumerable
  include Comparable

  def_delegators(
    :array,
    *%i[
      <<
      delete
      each
      include?
      size
      sort
      sort!
      to_a
      to_json
      uniq!
    ])

  def initialize(coordinates_array = [])
    @array =
      Array.wrap(coordinates_array).map { |coordinates|
        Conversions.Coordinates(coordinates)
      }
    freeze
  end

  def to_ary = self

  def <=>(other)
    other = Conversions.CoordinatesArray(other)
    to_a <=> other.to_a
  end

  private

  attr_reader :array

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      { self => array.map(&:inspect) }
    end

    private

    def inspect_info
      "x#{size}"
    end
  end
end
