# frozen_string_literal: true

# Games::Past::PerformanceMetrics::PersonalBest
class Games::Past::PerformanceMetrics::PersonalBest
  def initialize(context:, query_method:)
    @context = context
    @query_method = query_method
  end

  def for_the_alliance? = false
  def type_name = "personal"

  def presence
    self if present?
  end

  def present? = bests.public_send(query_method, game:)

  private

  attr_reader :context,
              :query_method

  def bests = context.user_bests
  def game = context.game
end
