# frozen_string_literal: true

# Games::Index is a View Model for displaying the Games Index page.
class Games::Index
  def self.turbo_stream_name = :sweep_ops_archive

  def initialize(base_arel:, context:)
    @base_arel = base_arel
    @context = context
  end

  def to_param = self.class.turbo_stream_name

  def show_time_zone_form?(user:) = user.participant?

  def time_zone_form(user:)
    Users::TimeZone::Form.new(user:)
  end

  def current_time_zone_description = Time.zone.to_s

  def types
    Type.wrap(Game::ALL_TYPES, type_filter:)
  end

  def engagement_tally
    EngagementTally.new(base_arel: arel)
  end

  def listings
    Games::Listings.new(base_arel: arel, context:)
  end

  private

  attr_reader :base_arel,
              :context

  def arel
    @arel ||= type_filter? ? base_arel.for_type(type_filter) : base_arel
  end

  def type_filter = context.params[:type]
  def type_filter? = type_filter.present?

  # Games::Index::Type wraps {Game::TYPES}, for display of the "Initials = Name"
  # map/legend + filter links.
  class Type
    include WrapMethodBehaviors

    def initialize(name, type_filter:)
      @name = name
      @type_filter = type_filter
    end

    def filter_name
      "(#{name.first})#{name[1..]}"
    end

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

    attr_reader :name,
                :type_filter

    def base_arel = Game.for_game_over_statuses

    def filter_active?
      type_filter&.include?(name)
    end

    def games_percent
      result = (games_count / total_games_count.to_f) * 100.0
      result.nan? ? 0.0 : result
    end

    def total_games_count = @total_games_count ||= base_arel.count
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
end
