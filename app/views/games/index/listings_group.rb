# frozen_string_literal: true

# Games::Index::ListingsGroup represents a group of {Game} listings on the Games
# Index page.
class Games::Index::ListingsGroup
  include WrapMethodBehaviors

  def initialize(date, base_arel:, context: nil)
    @date = date
    @base_arel = base_arel
    @context = context
  end

  def datetime_attribute
    I18n.l(date, format: :iso8601)
  end

  def to_s
    I18n.l(date, format: :weekday_comma_date)
  end

  def engagement_tally
    EngagementTally.new(date, base_arel:)
  end

  def listings
    Listing.wrap(listings_arel, context:)
  end

  private

  attr_reader :date,
              :base_arel,
              :context

  def listings_arel
    base_arel.for_end_date(date).by_most_recently_ended
  end
end
