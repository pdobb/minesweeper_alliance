# frozen_string_literal: true

# Users::Games::PaginatedListingsGroups represents the paginated groups of
# {Game} listings in the User Show page's Engagements section.
class Users::Games::PaginatedListingsGroups
  def initialize(base_arel:, user:, context:)
    @base_arel = base_arel
    @user = user
    @context = context
  end

  def turbo_target = Games::Index::PaginatedListingsGroups.turbo_target

  def listings_groups = listings_groups_builder.listings_groups
  def pager = listings_groups_builder.pager

  private

  attr_reader :base_arel,
              :user,
              :context

  def listings_groups_builder
    @listings_groups_builder ||=
      Users::Games::ListingsGroupsBuilder.new(base_arel:, user:, context:)
  end
end
