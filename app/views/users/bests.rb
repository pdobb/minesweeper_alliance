# frozen_string_literal: true

# Users::Bests represents the "Best Games" section--broken out by metrics
# (Score, 3BV/s, Efficiency) and then again by {Game#type}--on User Show pages.
class Users::Bests
  def initialize(user:)
    @user = user
  end

  def cache_key
    [
      user,
      :bests,
      completed_games_count,
    ]
  end

  def score = Metrics::Score.new(user:, user_bests:)
  def bbbvps = Metrics::BBBVPS.new(user:, user_bests:)
  def efficiency = Metrics::Efficiency.new(user:, user_bests:)

  private

  attr_reader :user

  def completed_games_count = user.completed_games_count
  def user_bests = @user_bests ||= user.bests
end
