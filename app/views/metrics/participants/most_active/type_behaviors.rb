# frozen_string_literal: true

# Metrics::Participants::MostActive::TypeBehaviors defines behaviors common to
# the Metrics::Participants::MostActive::<Type> models.
module Metrics::Participants::MostActive::TypeBehaviors
  def type = raise(NotImplementedError)

  def listings
    @listings ||=
      Metrics::Participants::MostActive::Listing.wrap_upto(
        arel,
        limit:,
        fill: Metrics::Participants::MostActive::NullListing.new)
  end

  private

  def arel = raise(NotImplementedError)

  def base_arel
    User.select(
      "users.*",
      "COUNT(participant_transactions.id) AS active_participation_count",
      "MAX(participant_transactions.created_at) AS most_recent_transaction").
      joins(:active_participant_transactions).
      group("users.id").
      order(active_participation_count: :desc).
      order(:most_recent_transaction)
  end

  def limit = Metrics::Show::TOP_RECORDS_LIMIT
end
