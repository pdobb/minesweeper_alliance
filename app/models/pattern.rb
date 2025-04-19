# frozen_string_literal: true

# :reek:TooManyMethods

# Pattern is a slimmed-down version of a {Board} and its associated {Cell}s,
# dedicated to "Draw Mode". Wherein we place Flags to produce a reusable pattern
# for placing mines in regular {Board} {Cell}s.
#
# @attr name [String] Uniquely identifies this Pattern.
# @attr settings [Hash] An object that stores the width and height of the {Grid}
#   of associated {Cell}s. Converted to {Pattern::Settings} via {#settings}
#   getter override.
# @attr coordinates_set [Array[Hash]] A list of "flagged" {Coordinates}.
#   These make up a minority of total possible {Coordinates} for the Pattern's
#   {Grid}. They are later translated into mine placements when a {Board} is
#   generated off of this Pattern.
class Pattern < ApplicationRecord
  self.implicit_order_column = "created_at"

  attribute :coordinates_set, CoordinatesSetType.new

  validates :name,
            presence: true,
            uniqueness: true

  validate :validate_settings

  def settings = @settings ||= Settings.new(**super)
  def width = settings.width
  def height = settings.height
  def cells_count = width * height
  def dimensions = settings.dimensions

  def grid
    Grid.new(cells)
  end

  def cells
    @cells ||= GenerateCells.(pattern: self)
  end

  def toggle_flag(coordinates)
    coordinates_set.toggle(coordinates)

    update!(coordinates_set:)

    self
  end

  def flag_density
    flags_count / cells_count.to_f
  end

  def flags_count = coordinates_set.size
  def mines = flags_count

  def flagged?(coordinates)
    coordinates_set.include?(coordinates)
  end

  def reset
    update!(coordinates_set: [])

    self
  end

  private

  def validate_settings
    return if settings.valid?

    errors.merge!(settings.errors)
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      { self => coordinates_set.introspect }
    end

    private

    def inspect_identification = identify

    def inspect_info(scope:)
      scope.join_info([
        dimensions,
        "#{Emoji.flag} x#{flags_count}",
      ])
    end

    def inspect_name = name
  end
end
