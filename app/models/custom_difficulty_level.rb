# frozen_string_literal: true

# CustomDifficultyLevel represents custom / user-supplied {Board} settings.
#
# @see DifficultyLevel
class CustomDifficultyLevel
  NAME = "Custom"

  include ActiveModel::Model
  include ActiveModel::Attributes

  include DifficultyLevelBehaviors

  def self.valid_values_for(setting)
    Board::VALID_SETTINGS_RANGES.fetch(setting)
  end

  def self.valid_mine_density_range
    Board::VALID_MINE_DENSITY_RANGE
  end

  attribute :width, :integer, default: -> { valid_values_for(:width).begin }
  attribute :height, :integer, default: -> { valid_values_for(:height).begin }
  attribute :mines, :integer, default: -> { valid_values_for(:mines).begin }

  validates :width,
            presence: true,
            numericality: {
              integer: true,
              in: valid_values_for(:width),
              allow_blank: true,
            }
  validates :height,
            presence: true,
            numericality: {
              integer: true,
              in: valid_values_for(:height),
              allow_blank: true,
            }
  validates :mines,
            presence: true,
            numericality: {
              integer: true,
              in: valid_values_for(:mines),
              allow_blank: true,
            }

  unless App.dev_mode? # rubocop:disable Style/IfUnlessModifier
    validate :validate_mine_density
  end

  def name = NAME

  private

  def validate_mine_density
    return if width.blank? || height.blank? || mines.blank?

    if too_sparse?
      errors.add(
        :mines,
        "must be >= #{minimum_mines} (10% of total area)")
    end

    if too_dense? # rubocop:disable Style/GuardClause
      errors.add(
        :mines,
        "must be <= #{maximum_mines} (#{maximum_ratio} of total area)")
    end
  end

  def too_sparse? = density_percent < minimum_ratio
  def too_dense? = density_percent > maximum_ratio
  def density_percent = mines / area.to_f
  def area = width * height

  def minimum_ratio = valid_mine_density_range.begin
  def maximum_ratio = valid_mine_density_range.end
  def valid_mine_density_range = self.class.valid_mine_density_range

  def minimum_mines
    (area * minimum_ratio).ceil
  end

  def maximum_mines
    (area * maximum_ratio).floor
  end
end
