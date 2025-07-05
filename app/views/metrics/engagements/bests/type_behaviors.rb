# frozen_string_literal: true

# Metrics::Engagements::Bests::TypeBehaviors defines behaviors common to
# the Metrics::Engagements::Bests::<Type> models.
module Metrics::Engagements::Bests::TypeBehaviors
  def type = raise(NotImplementedError)

  def listings
    @listings ||=
      Metrics::Engagements::Bests::Listing.wrap_upto(
        arel,
        limit:,
        fill: Metrics::Engagements::Bests::NullListing.new,
      )
  end

  private

  def arel = raise(NotImplementedError)

  def base_arel
    Game.for_status_alliance_wins.by_score_asc.limit(limit)
  end

  def limit = Metrics::Show::TOP_RECORDS_LIMIT
end
