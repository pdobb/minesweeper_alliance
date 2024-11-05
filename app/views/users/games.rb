# frozen_string_literal: true

# Users::Games represents a given {User}'s past {Game}s on the {User} Show page.
class Users::Games
  def initialize(base_arel:, user:)
    @base_arel = base_arel
    @user = user
  end

  def engagement_tally
    EngagementTally.new(user:, base_arel:)
  end

  def any_listings? = arel.any?

  def listings_grouped_by_date
    games_grouped_by_ended_at.
      transform_keys! { |date|
        ::Games::Index::ListingsDate.new(date, base_arel: arel)
      }. # rubocop:disable Style/MultilineBlockChain
      transform_values! { |games| Listing.wrap(games, user:) }
  end

  private

  attr_reader :base_arel,
              :user

  def arel = base_arel

  def games_grouped_by_ended_at
    arel.group_by { |game| game.ended_at.to_date }
  end

  # Users::Games::EngagementTally
  class EngagementTally
    include ::Games::Past::EngagementTallyBehaviors

    def initialize(user:, base_arel:)
      @user = user
      @base_arel = base_arel
    end

    private

    attr_reader :user,
                :base_arel

    def start_at = user.created_at
  end

  # Users::Games::Listing
  class Listing < ::Games::Index::Listing
    def initialize(model, user:)
      super(model)
      @user = user
    end

    def game_url
      Router.user_game_path(user, game)
    end

    private

    attr_reader :user
  end
end
