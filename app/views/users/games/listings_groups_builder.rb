# frozen_string_literal: true

# Users::Games::ListingsGroupsBuilder is a specialization on
# {Games::Index::ListingsGroupsBuilder} that builds
# {Users::Games::ListingsGroup}s--listings of {Game}s, grouped by
# activity date, for a given {User}--for the Users Show page's "Engagements"
# section.
class Users::Games::ListingsGroupsBuilder < Games::Index::ListingsGroupsBuilder
  def initialize(base_arel:, user:, context:)
    super(base_arel:, context:)
    @user = user
  end

  def listings_groups
    Users::Games::ListingsGroup.wrap(activity_dates, base_arel:, user:)
  end

  private

  attr_reader :user

  def next_page_url
    Router.user_games_path(
      user,
      cursor: paginated_activity_dates.cursor,
      format: :turbo_stream,
    )
  end
end
