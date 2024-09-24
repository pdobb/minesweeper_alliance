# frozen_string_literal: true

# EngagementTallyBehaviors is a View Model wrapper around {EngagementTally},
# for displaying engagement tally details in the view template.
module EngagementTallyBehaviors
  def wins_count = engagement_tally.wins_count
  def losses_count = engagement_tally.losses_count
  def alliance_leads? = engagement_tally.alliance_leads?

  def alliance_ranking_css_color
    if alliance_leads?
      %w[text-green-700 dark:text-green-600]
    else
      %w[text-red-700 dark:text-red-600]
    end
  end

  private

  def engagement_tally
    raise(NotImplementedError)
  end
end

# Games::Index is a view model for displaying the Games Index page.
class Games::Index
  include EngagementTallyBehaviors

  attr_reader :base_arel

  def self.current_time_zone_description
    Rails.configuration.time_zone
  end

  def initialize(base_arel:)
    @base_arel = base_arel
  end

  def current_time_zone_description = self.class.current_time_zone_description

  def presets
    Preset.wrap(
      Board::Settings::PRESETS.keys.including(Board::Settings::CUSTOM))
  end

  def any_listings?
    base_arel.any?
  end

  def listings_grouped_by_date
    games_grouped_by_ended_at.
      transform_keys! { |date| ListingsDate.new(date) }.
      transform_values! { |games| Listing.wrap(games) }
  end

  private

  def games_grouped_by_ended_at
    base_arel.group_by { |game| game.ended_at.to_date }
  end

  def engagement_tally
    start_at = App.created_at
    @engagement_tally ||= EngagementTally.new(start_at..)
  end

  # Games::Index::Preset wraps {Board::Settings} presets (names), for display
  # of the "Initials = Name" map/legend.
  class Preset
    include WrapMethodBehaviors

    def initialize(preset) = @preset = preset
    def initials = name[0]
    def name = @preset
  end

  # Games::Index::ListingsDate
  class ListingsDate
    include EngagementTallyBehaviors

    attr_reader :date

    def initialize(date)
      @date = date
    end

    def to_s
      I18n.l(date, format: :weekday_comma_date)
    end

    private

    def engagement_tally
      @engagement_tally ||= EngagementTally.new(start_time..end_time)
    end

    def start_time
      date.in_time_zone.at_beginning_of_day
    end

    def end_time
      date.in_time_zone.at_end_of_day
    end
  end

  # Games::Index::Listing
  class Listing
    include ActiveModelWrapperBehaviors
    include Games::ShowBehaviors
    include WrapMethodBehaviors

    def initialize(model)
      @model = model
    end

    def difficulty_level_indicator
      difficulty_level[0]
    end

    def game_engagement_time_range(template)
      template.safe_join(
        [
          I18n.l(to_model.started_at, format: :time),
          I18n.l(to_model.ended_at, format: :time),
        ],
        "&ndash;".html_safe)
    end

    def game_url(router = RailsRouter.instance)
      router.game_path(to_model)
    end

    private

    def to_model = @model
  end
end
