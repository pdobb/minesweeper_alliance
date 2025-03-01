# frozen_string_literal: true

# Games::Index::PaginatedListingsGroups represents the paginated groups of
# {Game} listings in the Games Index page.
class Games::Index::PaginatedListingsGroups
  def self.turbo_target = "paginatedListingsGroups"

  def initialize(base_arel:, context:)
    @base_arel = base_arel
    @context = context
  end

  def turbo_target = self.class.turbo_target

  def type
    type_filter if type_filter?
  end

  def listings_groups = listings_groups_builder.listings_groups
  def pager = listings_groups_builder.pager

  private

  attr_reader :base_arel,
              :context

  def type_filter = context.params[:type]
  def type_filter? = type_filter.present?

  def listings_groups_builder
    @listings_groups_builder ||=
      Games::Index::ListingsGroupsBuilder.new(base_arel:, context:)
  end
end
