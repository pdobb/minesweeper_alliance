# frozen_string_literal: true

# Games::Index is a View Model for displaying the Games Index page.
class Games::Index
  def self.current_time_zone_description
    Time.zone.to_s
  end

  def initialize(base_arel:, type_filter:)
    @base_arel = base_arel
    @type_filter = type_filter
  end

  def time_zone_form(user:)
    TimeZoneForm.new(user:)
  end

  def current_time_zone_description = self.class.current_time_zone_description

  def types
    Type.wrap(Board::Settings::ALL_TYPES, type_filter:)
  end

  def engagement_tally
    EngagementTally.new(base_arel:)
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

  # Games::Index::TimeZoneForm wraps the drop-down/select form that updates
  # {User#time_zone}.
  class TimeZoneForm
    def initialize(user:)
      @user = user
    end

    def to_model = UserWrapper.new(@user)

    def post_url
      router.current_user_time_zone_update_path
    end

    def priority_zones = ActiveSupport::TimeZone.us_zones

    private

    def router = RailsRouter.instance

    # Games::Index::TimeZoneForm::UserWrapper is a Form View Model for
    # representing {User}s.
    class UserWrapper
      def initialize(user)
        @user = user
      end

      def model_name = @user.model_name

      def time_zone
        @user.time_zone || Time.zone.name
      end
    end
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

    def games_filter_url
      if filter_active?
        router.games_path
      else
        router.games_path(type: name)
      end
    end

    def css
      "active" if filter_active?
    end

    def games_percent
      result = (games_count / total_games_count.to_f) * 100.0
      result.nan? ? 0.0 : result
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

    def router = RailsRouter.instance
  end

  # Games::Index::EngagementTally
  class EngagementTally
    include Games::EngagementTallyBehaviors

    def initialize(base_arel:)
      @base_arel = base_arel
    end

    private

    attr_reader :base_arel

    def start_at = App.created_at
  end

  # Games::Index::ListingsDate
  class ListingsDate
    include Games::EngagementTallyBehaviors

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

    def start_at
      date.in_time_zone.at_beginning_of_day
    end

    def end_at
      date.in_time_zone.at_end_of_day
    end
  end

  # Games::Index::Listing
  class Listing
    include Games::ShowBehaviors
    include WrapMethodBehaviors

    def initialize(game)
      @game = game
    end

    def type_indicator
      type[0]
    end

    def game_score = _game_score.round(0)
    def show_game_score? = !!_game_score

    def game_engagement_time_range(template)
      template.safe_join(
        [
          I18n.l(game.started_at, format: :time),
          I18n.l(game.ended_at, format: :time),
        ],
        "&ndash;".html_safe)
    end

    def game_url
      router.game_path(game)
    end

    private

    attr_reader :game

    def _game_score = game.score

    def router = RailsRouter.instance
  end
end
