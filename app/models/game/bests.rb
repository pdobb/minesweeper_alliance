# frozen_string_literal: true

# Game::Bests provides methods for finding the "Best Games" (top scoring, lowest
# 3BV/s, highest efficiency) bucketed by {Game#type}. Only the buckets
# corresponding with {Game::BESTABLE_TYPES} are available.
module Game::Bests
  def self.for_type(type) = public_send(type.downcase)

  def self.beginner = @beginner ||= Beginner.new
  def self.intermediate = @intermediate ||= Intermediate.new
  def self.expert = @expert ||= Expert.new

  # Game::Bests::Behaviors defines common behaviors for the various types
  # herein.
  module Behaviors
    # Determine if the passed in {Game} matches that of the best performance for
    # each category.

    def score?(game) = game && score == game
    def bbbvps?(game) = game && bbbvps == game
    def efficiency?(game) = game && efficiency == game

    # @example
    #   Game::Bests.beginner.any?(Game.first)
    def any?(game) = categories(game).any?

    # @example
    #   Game::Bests.expert.categories(Game.bests_for_expert_type.take)
    #   # => ["Score", "Efficiency"]
    def categories(game)
      return [] unless game

      [
        ("Score" if score?(game)),
        ("3BV/s" if bbbvps?(game)),
        ("Efficiency" if efficiency?(game)),
      ].tap(&:compact!)
    end

    private

    def base_arel = Game.for_status_alliance_wins
    def score_arel = base_arel.by_score_asc
    def bbbvps_arel = base_arel.by_bbbvps_desc
    def efficiency_arel = base_arel.by_efficiency_desc
  end

  # Game::Bests::Beginner provides accessors for {Game#type} == "Beginner".
  class Beginner
    include Behaviors

    def score = score_arel.for_beginner_type.take
    def bbbvps = bbbvps_arel.for_beginner_type.take
    def efficiency = efficiency_arel.for_beginner_type.take
  end

  # Game::Bests::Intermediate provides accessors for {Game#type} ==
  # "Intermediate".
  class Intermediate
    include Behaviors

    def score = score_arel.for_intermediate_type.take
    def bbbvps = bbbvps_arel.for_intermediate_type.take
    def efficiency = efficiency_arel.for_intermediate_type.take
  end

  # Game::Bests::Expert provides accessors for {Game#type} == "Expert".
  class Expert
    include Behaviors

    def score = score_arel.for_expert_type.take
    def bbbvps = bbbvps_arel.for_expert_type.take
    def efficiency = efficiency_arel.for_expert_type.take
  end
end
