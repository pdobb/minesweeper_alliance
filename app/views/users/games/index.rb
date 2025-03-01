# frozen_string_literal: true

# Users::Games::Index represents a given {User}'s past {Game}s on the User Show
# page.
class Users::Games::Index
  def initialize(base_arel:, user:, context:)
    @base_arel = base_arel
    @user = user
    @context = context
  end

  def engagement_tally
    Users::Games::EngagementTally.new(user:, base_arel:)
  end

  def paginated_listings_groups
    Users::Games::PaginatedListingsGroups.new(base_arel:, user:, context:)
  end

  private

  attr_reader :base_arel,
              :user,
              :context
end
