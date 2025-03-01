# frozen_string_literal: true

# Games::Index::ListingsGroupsBuilder builds
# {Games::Index::ListingsGroup}s--listings of {Game}s, grouped by
# activity date--on the Games Index page.
#
# The collection of {Games::Index::ListingsGroup}s built may be optionally
# filtered by {Game#type} using `params[:type]` (via the passed-in `context`).
class Games::Index::ListingsGroupsBuilder
  PER_PAGE = 10

  def initialize(base_arel:, context:)
    @base_arel = base_arel
    @context = context
  end

  def listings_groups
    Games::Index::ListingsGroup.wrap(activity_dates, base_arel:, context:)
  end

  def pager
    if paginated_activity_dates.next_page?
      Application::Pager.new(url: next_page_url)
    else
      Application::EmptyPager.new
    end
  end

  private

  attr_reader :base_arel,
              :context

  def activity_dates = paginated_activity_dates.to_a

  def paginated_activity_dates(per_page: PER_PAGE)
    @paginated_activity_dates ||=
      Paginate.(activity_dates_arel, per_page:, cursor:)
  end

  # :reek:FeatureEnvy
  def activity_dates_arel(time_zone: Time.zone.tzinfo.name)
    date_expression =
      Arel.sql("DATE(ended_at AT TIME ZONE :time_zone)", time_zone:)

    base_arel.
      select(date_expression.as("end_date")).
      group(date_expression).
      order(date_expression.desc)
  end

  def cursor
    Date.parse(cursor_param) if cursor_param?
  end

  def cursor_param = context.params[:cursor]
  def cursor_param? = cursor_param.present?

  def next_page_url
    Router.games_path(
      **filter_params,
      cursor: paginated_activity_dates.cursor,
      format: :turbo_stream)
  end

  def filter_params = query_parameters.slice(:type)
  def query_parameters = context.query_parameters

  # Games::Index::ListingsGroupsBuilder::Paginate handles pagination of activity
  # dates for the passed-in `base_arel` (collection of {Game}s). i.e. we're
  # paginating a given number of days of activity. Later, another object will
  # use this paginated collection of dates to find the actual associated
  # {Game}s/listings for that date themselves.
  #
  # Paginating by date is better than paginating by {Game}s, directly, as this
  # would likely result in split dates--where some {Game}s are left off a date
  # on page 1, and then must be continued for the remaining games for that date
  # on page 2.
  class Games::Index::ListingsGroupsBuilder::Paginate
    include CallMethodBehaviors

    attr_reader :cursor

    def initialize(base_arel, per_page:, cursor:)
      @base_arel = base_arel
      @per_page = per_page
      @cursor = cursor
    end

    def call
      self.records = load_arel
      self.cursor = next_page_cursor

      self
    end

    def to_a = records
    def next_page? = cursor?

    private

    attr_reader :base_arel,
                :per_page
    attr_accessor :records
    attr_writer :cursor

    def load_arel
      Game.connection.select_values(arel.to_sql, "Game Pluck End Dates")
    end

    def arel
      arel = base_arel.for_end_date_on_or_before(cursor) if cursor?
      (arel || base_arel).limit(per_page.next)
    end

    def cursor? = !!cursor

    def next_page_cursor
      records.pop if records.size > per_page
    end
  end
end
