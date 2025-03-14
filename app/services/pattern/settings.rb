# frozen_string_literal: true

# Pattern::Settings stores the {#width} and {#height} of the {Grid} of
# {Cell}s (to be) for the associated {Pattern}.
class Pattern::Settings
  RANGES = {
    width: Board::Settings::RANGES.fetch(:width),
    height: Board::Settings::RANGES.fetch(:height),
  }.freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :width, :integer, default: -> { RANGES.fetch(:width).begin }
  attribute :height, :integer, default: -> { RANGES.fetch(:height).begin }

  validates :width,
            presence: true,
            numericality: {
              integer: true,
              in: RANGES.fetch(:width),
              allow_blank: true,
            }
  validates :height,
            presence: true,
            numericality: {
              integer: true,
              in: RANGES.fetch(:height),
              allow_blank: true,
            }

  # Shortcut for Custom Settings: See {RANGES}.
  #
  # @example
  #   Pattern::Settings[12, 20]
  def self.[](*args)
    new(width: args[0], height: args[1])
  end

  def to_h = { width:, height: }
  def to_a = to_h.values
  def as_json = to_h

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    private

    def inspect_identification = identify(:width, :height)
  end
end
