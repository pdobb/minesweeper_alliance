# frozen_string_literal: true

# EngagementTallyBehaviors is a View Model wrapper around {EngagementTally},
# for displaying engagement tally details in the view template.
module EngagementTallyBehaviors
  def wins_count = engagement_tally.wins_count
  def losses_count = engagement_tally.losses_count
  def alliance_leads? = engagement_tally.alliance_leads?
  def mines_lead? = engagement_tally.mines_lead?

  def alliance_ranking_css_color
    if alliance_leads?
      %w[text-green-700 dark:text-green-600]
    elsif mines_lead?
      %w[text-red-700 dark:text-red-600]
    end
  end

  private

  def engagement_tally
    raise(NotImplementedError)
  end
end

# Games::Index is a View Model for displaying the Games Index page.
class Games::Index
  include EngagementTallyBehaviors

  def self.current_time_zone_description
    Rails.configuration.time_zone
  end

  def initialize(base_arel:, type_filter:)
    @base_arel = base_arel
    @type_filter = type_filter
  end

  def current_time_zone_description = self.class.current_time_zone_description

  def types
    Type.wrap(Board::Settings::ALL_TYPES, type_filter:)
  end

  def any_listings?
    arel.any?
  end

  def listings_grouped_by_date
    games_grouped_by_ended_at.
      transform_keys! { |date| ListingsDate.new(date, base_arel: arel) }.
      transform_values! { |games| Listing.wrap(games) }
  end

  private

  attr_reader :base_arel,
              :type_filter

  def arel
    arel = base_arel
    arel = arel.for_type(type_filter) if type_filter
    arel
  end

  def games_grouped_by_ended_at
    arel.group_by { |game| game.ended_at.to_date }
  end

  def engagement_tally
    start_at = App.created_at
    @engagement_tally ||= EngagementTally.new(start_at.., base_arel: arel)
  end

  # Games::Index::Type wraps {Board::Settings} types, for display of the
  # "Initials = Name" map/legend.
  class Type
    include WrapMethodBehaviors

    def self.total_games_count = @total_games_count ||= base_arel.count
    def self.base_arel = Game.for_game_over_statuses

    def initialize(preset, type_filter:)
      @preset = preset
      @type_filter = type_filter
    end

    def initials = name[0]
    def name = preset

    def games_filter_url(router = RailsRouter.instance)
      if filter_active?
        router.games_path
      else
        router.games_path(type: name)
      end
    end

    def css_classes
      "active" if filter_active?
    end

    def games_percent
      (games_count / total_games_count.to_f) * 100.0
    end

    def games_count = @games_count ||= base_arel.for_type(name).count

    private

    attr_reader :preset,
                :type_filter

    def base_arel = self.class.base_arel
    def total_games_count = self.class.total_games_count

    def filter_active?
      type_filter&.include?(name)
    end
  end

  # Games::Index::ListingsDate
  class ListingsDate
    include EngagementTallyBehaviors

    attr_reader :date

    def initialize(date, base_arel:)
      @date = date
      @base_arel = base_arel
    end

    def to_s
      I18n.l(date, format: :weekday_comma_date)
    end

    private

    attr_reader :base_arel

    def engagement_tally
      @engagement_tally ||=
        EngagementTally.new(start_time..end_time, base_arel:)
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

    def type_indicator
      type[0]
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
