# frozen_string_literal: true

# Board::Settings::MineDensityValidator validates Mine Density limits on Custom
# {Game}s.
class Board::Settings::MineDensityValidator < ActiveModel::Validator
  # :reek:UtilityFunction
  def validate(settings)
    Validate.(settings)
  end

  # Board::Settings::MineDensityValidator::Validate performs the actual
  # Validation for {Board::Settings::MineDensityValidator}.
  class Validate
    def self.call(...) = new(...).call

    def initialize(settings)
      @settings = settings
    end

    def call
      return if errors.any?

      if too_sparse?
        errors.add(
          :mines,
          "must be >= #{minimum_mines} "\
          "(#{minimum_density_percentage} of total area)",
        )
      end

      if too_dense?
        errors.add(
          :mines,
          "must be <= #{maximum_mines} (#{maximum_density} of total area)",
        )
      end
    end

    private

    attr_reader :settings

    def errors = settings.errors

    def area = settings.width * settings.height
    def density = settings.mines / area.to_f

    def too_sparse? = density < minimum_density
    def minimum_mines = (area * minimum_density).ceil
    def minimum_density = Board::Settings::RANGES[:mine_density].begin
    def minimum_density_percentage = to_percentage(minimum_density * 100.0)

    def too_dense? = density > maximum_density
    def maximum_mines = (area * maximum_density).floor
    def maximum_density = Board::Settings::RANGES[:mine_density].end

    def to_percentage(number, precision: 0, **)
      ActiveSupport::NumberHelper::NumberToPercentageConverter.convert(
        number, precision:, **
      )
    end
  end
end
