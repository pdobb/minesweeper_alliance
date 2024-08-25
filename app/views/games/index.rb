# frozen_string_literal: true

# Games::Index is a view model for displaying the Games Index page.
class Games::Index
  attr_reader :base_arel

  def self.current_time_zone_description
    Rails.configuration.time_zone
  end

  def initialize(base_arel:)
    @base_arel = base_arel
  end

  def current_time_zone_description = self.class.current_time_zone_description

  def difficulty_levels
    DifficultyLevel.wrap(::DifficultyLevel.all)
  end

  def listings_grouped_by_date
    games_grouped_by_date.
      transform_keys! { |date| ListingsDate.new(date) }.
      transform_values! { |games| Listing.wrap(games) }
  end

  private

  def games_grouped_by_date
    base_arel.group_by { |game| game.updated_at.to_date }
  end

  # Games::Index::DifficultyLevel wraps {::DifficultyLevel#name}s, for display
  # of an "Initials" = "Name" map/legend.
  class DifficultyLevel
    include Games::DifficultyLevelBehaviors

    def initials = to_model.initials
  end

  # Games::Index::ListingsDate
  class ListingsDate
    attr_reader :date

    def initialize(date)
      @date = date
    end

    def to_s
      I18n.l(date, format: :weekday_comma_date)
    end
  end

  # Games::Index::Listing
  class Listing
    include ActiveModelWrapperBehaviors
    include Games::StatusBehaviors
    include WrapMethodBehaviors

    def initialize(model)
      @model = model
    end

    def game_ended_in_victory? = to_model.ended_in_victory?

    def game_number
      game_id.to_s.rjust(4, "0")
    end

    def difficulty_level_name
      difficulty_level.name
    end

    def difficulty_level_indicator
      difficulty_level.initials
    end

    def game_url(router = RailsRouter.instance)
      router.game_path(to_model)
    end

    def game_completed_at
      I18n.l(to_model.updated_at, format: :time)
    end

    private

    def to_model = @model
    def game_id = to_model.id
    def difficulty_level = to_model.difficulty_level
  end
end
