# frozen_string_literal: true

# Users::Games::ListingsGroup is a specialization on
# {Games::Index::ListingsGroup} that represents a group of {Game} listings in
# the User Show page's "Engagements" section.
class Users::Games::ListingsGroup < Games::Index::ListingsGroup
  def initialize(date, base_arel:, user:)
    super(date, base_arel:)
    @user = user
  end

  def listings
    Listing.wrap(listings_arel, user:)
  end

  private

  attr_reader :user
end
