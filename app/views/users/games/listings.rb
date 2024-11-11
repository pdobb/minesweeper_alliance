# frozen_string_literal: true

# Users::Games::Listings
class Users::Games::Listings
  def initialize(base_arel:, user:)
    @base_arel = base_arel
    @user = user
  end

  def any? = arel.any?

  def listings_grouped_by_date
    games_grouped_by_ended_at.
      transform_keys! { |date|
        Games::Listings::ListingsDate.new(date, base_arel: arel)
      }. # rubocop:disable Style/MultilineBlockChain
      transform_values! { |games| Listing.wrap(games, user:) }
  end

  attr_reader :base_arel,
              :user

  def arel = base_arel

  def games_grouped_by_ended_at
    arel.group_by { |game| game.ended_at.to_date }
  end

  # Users::Games::Listings::Listing
  class Listing < Games::Listings::Listing
    def initialize(game, user:)
      super(game)
      @user = user
    end

    def game_url
      Router.user_game_path(user, game)
    end

    private

    attr_reader :user
  end
end
