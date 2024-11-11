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

  def listings
    Users::Games::Listings.new(base_arel:, user:)
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
end
