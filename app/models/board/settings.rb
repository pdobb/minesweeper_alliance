# frozen_string_literal: true

# Board::Settings stores the {#type}, {#width}, {#height}, and number of
# {#mines} (to be) in the {Grid} of a {Board}'s associated {Cell}s.
class Board::Settings
  # rubocop:disable Layout/HashAlignment, Layout/LineLength
  PRESETS = {
    Game::BEGINNER_TYPE     => { width: 9,  height: 9,  mines: 10 }, # 12.3% mine density
    Game::INTERMEDIATE_TYPE => { width: 16, height: 16, mines: 40 }, # 15.6% mine density
    Game::EXPERT_TYPE       => { width: 30, height: 16, mines: 99 }, # 20.6% mine density
  }.freeze
  # rubocop:enable Layout/HashAlignment, Layout/LineLength

  PERCENT_CHANCE_FOR_RANDOM_PRESET = 90

  RANGES = {
    width: 6..30,
    height: 6..30,
    mines: 4..299,
    mine_density: 1/10r..1/3r,
  }.freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  include ObjectInspector::InspectorsHelper

  attribute :type, :string
  attribute :name, :string
  attribute :width, :integer, default: -> { RANGES.fetch(:width).begin }
  attribute :height, :integer, default: -> { RANGES.fetch(:height).begin }
  attribute :mines, :integer, default: -> { RANGES.fetch(:mines).begin }

  validates :type, presence: true
  validates :name, presence: { if: :pattern? }

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

  unless App.dev_mode?
    validates_with(Board::Settings::MineDensityValidator, if: :custom?)
  end

  def self.preset(type)
    raise(TypeError, "type can't be blank") if type.blank?

    new(type:, **settings_for(type))
  end

  def self.beginner = new(**settings_for("Beginner"))
  def self.intermediate = new(**settings_for("Intermediate"))
  def self.expert = new(**settings_for("Expert"))

  def self.settings_for(type)
    type = type.to_s.titleize
    { type:, **PRESETS.fetch(type) }
  end
  private_class_method :settings_for

  def self.random
    if Pattern.none? || PercentChance.(PERCENT_CHANCE_FOR_RANDOM_PRESET)
      preset(PRESETS.keys.sample)
    else # 10% of the time:
      random_pattern
    end
  end

  def self.random_pattern
    name = Pattern.by_random.limit(1).pick(:name)
    pattern(name)
  end

  def self.pattern(name)
    pattern = Pattern.find_by!(name:)
    new(
      type: Game::PATTERN_TYPE,
      name: pattern.name,
      width: pattern.width,
      height: pattern.height,
      mines: pattern.mines)
  end

  # Custom Settings: See {RANGES}.
  def self.custom(**) = new(type: Game::CUSTOM_TYPE, **)

  # Shortcut for Custom Settings: See {RANGES}.
  #
  # @example
  #   Board::Settings[12, 20, 30]
  def self.[](*args)
    custom(width: args[0], height: args[1], mines: args[2])
  end

  def pattern? = type == Game::PATTERN_TYPE
  def custom? = type == Game::CUSTOM_TYPE

  def to_s = type
  def to_h = { type:, name:, width:, height:, mines: }.tap(&:compact!)
  def as_json = to_h
  def to_a = to_h.values

  private

  def inspect_identification = identify(:width, :height, :mines)

  def inspect_name
    pattern? ? "#{type} (#{name.inspect})" : type
  end
end
