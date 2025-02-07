# frozen_string_literal: true

# Games::Past::PerformanceMetrics::AllianceBest
class Games::Past::PerformanceMetrics::AllianceBest
  def initialize(context:, query_method:)
    @context = context
    @query_method = query_method
  end

  def type_name = "alliance"

  def presence
    self if present?
  end

  def present? = bests.public_send(query_method)

  private

  attr_reader :context,
              :query_method

  def bests = context.game_bests
end
