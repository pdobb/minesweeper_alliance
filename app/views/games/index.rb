# frozen_string_literal: true

# Games::Index represents the Games Index page.
class Games::Index
  def self.turbo_stream_name = :sweep_ops_archive
  def self.turbo_stream_dom_id = "#{turbo_stream_name}_turbo_stream"

  def initialize(base_arel:, context:)
    @base_arel = base_arel
    @context = context
  end

  def to_param = self.class.turbo_stream_name
  def turbo_stream_dom_id = self.class.turbo_stream_dom_id

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

  def paginated_listings_groups
    PaginatedListingsGroups.new(base_arel: arel, context:)
  end

  private

  attr_reader :base_arel,
              :context

  def type_filter = context.params[:type]
  def type_filter? = type_filter.present?

  def arel
    @arel ||= type_filter? ? base_arel.for_type(type_filter) : base_arel
  end
end
