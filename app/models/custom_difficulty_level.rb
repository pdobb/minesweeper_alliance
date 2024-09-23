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
    Board::VALID_SETTINGS_VALUES_RANGES.fetch(setting)
  end

  def self.valid_densities_range_as_percents
    Board::VALID_MINES_DENSITY_RANGE_AS_PERCENT
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
    validate :validate_mines_density
  end

  def name = NAME

  private

  def validate_mines_density
    return if width.blank? || height.blank? || mines.blank?

    if too_sparse?
      errors.add(
        :mines,
        "must be >= #{minimum_mines_count} (#{minimum_percent}% of total area)")
    end

    if too_dense? # rubocop:disable Style/GuardClause
      errors.add(
        :mines,
        "must be <= #{maximum_mines_count} (#{maximum_percent}% of total area)")
    end
  end

  def too_sparse? = density_percent < minimum_percent
  def too_dense? = density_percent > maximum_percent
  def density_percent = (mines / area.to_f) * 100.0
  def area = width.to_i * height.to_i

  def minimum_percent = valid_densities_range_as_percents.begin
  def maximum_percent = valid_densities_range_as_percents.end

  def valid_densities_range_as_percents
    self.class.valid_densities_range_as_percents
  end

  def minimum_mines_count
    (area * (minimum_percent / 100.0)).ceil
  end

  def maximum_mines_count
    (area * (maximum_percent / 100.0)).floor
  end
end
