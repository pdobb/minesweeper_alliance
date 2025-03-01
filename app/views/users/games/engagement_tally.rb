# frozen_string_literal: true

# Users::Games::EngagementTally
class Users::Games::EngagementTally
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
