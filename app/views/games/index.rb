# frozen_string_literal: true

# Games::Index is a View Model for displaying the Games Index page.
class Games::Index
  def self.turbo_stream_name = :sweep_ops_archive

  def self.current_time_zone_description
    Time.zone.to_s
  end

  def initialize(base_arel:, type_filter:)
    @base_arel = base_arel
    @type_filter = type_filter
  end

  def turbo_stream_name = self.class.turbo_stream_name

  def time_zone_form(user:)
    Users::TimeZone::Form.new(user:)
  end

  def current_time_zone_description = self.class.current_time_zone_description

  def types
    Type.wrap(Game::ALL_TYPES, type_filter:)
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

  # Games::Index::Type wraps {Game::TYPES}, for display of the "Initials = Name"
  # map/legend.
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
        Router.games_path
      else
        Router.games_path(type: name)
      end
    end

    def css
      "active" if filter_active?
    end

    def games_count = @games_count ||= base_arel.for_type(name).count

    def games_percentage
      View.percentage(games_percent, precision: 0)
    end

    private

    attr_reader :preset,
                :type_filter

    def base_arel = self.class.base_arel
    def total_games_count = self.class.total_games_count

    def filter_active?
      type_filter&.include?(name)
    end

    def games_percent
      result = (games_count / total_games_count.to_f) * 100.0
      result.nan? ? 0.0 : result
    end
  end

  # Games::Index::EngagementTally
  class EngagementTally
    include Games::Past::EngagementTallyBehaviors

    def initialize(base_arel:)
      @base_arel = base_arel
    end

    private

    attr_reader :base_arel

    def start_at = App.created_at
  end

  # Games::Index::ListingsDate
  class ListingsDate
    include Games::Past::EngagementTallyBehaviors

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
    include WrapMethodBehaviors

    def initialize(game)
      @game = game
    end

    def game_url
      Router.game_path(game)
    end

    def game_number = game.display_id
    def type = game.type
    def type_indicator = type[0]

    def show_game_score? = !!_game_score
    def game_score = View.round(_game_score, precision: 0)

    def game_status_mojis
      if game_ended_in_defeat?
        Emoji.mine
      elsif game_ended_in_victory?
        "#{Emoji.ship}#{Emoji.victory}"
      end
    end

    private

    attr_reader :game

    def _game_score = game.score

    def game_ended_in_victory? = game.ended_in_victory?
    def game_ended_in_defeat? = game.ended_in_defeat?
  end
end
