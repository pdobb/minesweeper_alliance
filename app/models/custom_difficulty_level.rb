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

  def name = NAME
end
