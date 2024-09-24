# frozen_string_literal: true

# Board::Settings stores the {#name}, {#width}, {#height}, and number of
# {#mines} (to be) in the {Grid} of a {Board}'s associated {Cell}s.
class Board::Settings
  # rubocop:disable Layout/HashAlignment
  PRESETS = {
    "Beginner" =>     { width: 9,  height: 9,  mines: 10 }, # 12.3% mine density
    "Intermediate" => { width: 16, height: 16, mines: 40 }, # 15.6% mine density
    "Expert" =>       { width: 30, height: 16, mines: 99 }, # 47.6% mine density
  }.freeze
  # rubocop:enable Layout/HashAlignment

  CUSTOM = "Custom"

  RANGES = {
    width: 6..30,
    height: 6..30,
    mines: 4..299,
    mine_density: (1/10r)..(1/3r),
  }.freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  include ObjectInspector::InspectorsHelper

  attribute :name, :string
  attribute :width, :integer, default: -> { RANGES.fetch(:width).begin }
  attribute :height, :integer, default: -> { RANGES.fetch(:height).begin }
  attribute :mines, :integer, default: -> { RANGES.fetch(:mines).begin }

  validates :name,
            presence: true

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
  validates :mines,
            presence: true,
            numericality: {
              integer: true,
              in: RANGES.fetch(:mines),
              allow_blank: true,
            }

  unless App.dev_mode? # rubocop:disable Style/IfUnlessModifier
    validate :validate_mine_density, if: :custom?
  end

  def self.preset(name)
    raise(TypeError, "name can't be blank") if name.blank?

    new(name:, **settings_for(name))
  end

  def self.beginner = new(**settings_for("Beginner"))
  def self.intermediate = new(**settings_for("Intermediate"))
  def self.expert = new(**settings_for("Expert"))
  def self.random = preset(PRESETS.keys.sample)

  def self.settings_for(name)
    name = name.to_s.titleize
    { name:, **PRESETS.fetch(name) }
  end
  private_class_method :settings_for

  # Custom Settings: See {RANGES}.
  def self.custom(**) = new(name: CUSTOM, **)

  # Shortcut for Custom Settings: See {RANGES}.
  #
  # @example
  #   Board::Settings[12, 20, 30]
  def self.[](*args)
    custom(width: args[0], height: args[1], mines: args[2])
  end

  def to_s = name
  def to_h = { name:, width:, height:, mines: }
  def to_a = to_h.values

  private

  def inspect_identification = identify(:width, :height, :mines)
  def inspect_name = name

  def validate_mine_density
    return if errors.any?

    if too_sparse?
      errors.add(
        :mines,
        "must be >= #{minimum_mines} "\
        "(#{minimum_density_percentage} of total area)")
    end

    if too_dense?
      errors.add(
        :mines,
        "must be <= #{maximum_mines} (#{maximum_density} of total area)")
    end
  end

  def custom? = name == CUSTOM

  def area = width * height
  def density = mines / area.to_f

  def too_sparse? = density < minimum_density
  def minimum_mines = (area * minimum_density).ceil
  def minimum_density = RANGES[:mine_density].begin
  def minimum_density_percentage = to_percentage(minimum_density * 100.0)

  def too_dense? = density > maximum_density
  def maximum_mines = (area * maximum_density).floor
  def maximum_density = RANGES[:mine_density].end

  def to_percentage(number, precision: 0, **)
    ActiveSupport::NumberHelper::NumberToPercentageConverter.convert(
      number, precision:, **)
  end
end
