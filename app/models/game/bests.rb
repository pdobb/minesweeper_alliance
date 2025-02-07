# frozen_string_literal: true

# Game::Bests provides methods for determining if the given {Game} is the "Best"
# of any of the "Bestable" types (Score, 3BV/s, Efficiency).
#
# The given {Game}'s {Game#type} must be in {Game::BESTABLE_TYPES} to work here.
# Ensuring this is left up to the caller. (See {Game#bests}.)
class Game::Bests
  def initialize(game)
    @game = game
  end

  def for_type(type) = public_send(type.downcase)

  def beginner = @beginner ||= Beginner.new(game:)
  def intermediate = @intermediate ||= Intermediate.new(game:)
  def expert = @expert ||= Expert.new(game:)

  private

  attr_reader :game

  # :reek:ModuleInitialize

  # Game::Bests::Behaviors defines common behaviors for the various types
  # herein.
  module Behaviors
    attr_reader :game

    def initialize(game:)
      @game = game
    end

    # Determine if the given {Game} matches that of the best performance for
    # each category. Example: `Game.last.bests.score?`

    def score? = score_arel.pick(:id) == game.id
    def bbbvps? = bbbvps_arel.pick(:id) == game.id
    def efficiency? = efficiency_arel.pick(:id) == game.id

    # @example
    #   Game.for_bests_of_type_beginner.take.bests.categories
    #   # => ["Score", "Efficiency"]
    def categories
      @categories ||= [
        ("Score" if score?),
        ("3BV/s" if bbbvps?),
        ("Efficiency" if efficiency?),
      ].tap(&:compact!)
    end

    private

    def base_arel = Game.for_status_alliance_wins
    def score_base_arel = base_arel.by_score_asc.by_least_recent
    def bbbvps_base_arel = base_arel.by_bbbvps_desc.by_least_recent
    def efficiency_base_arel = base_arel.by_efficiency_desc.by_least_recent
  end

  # Game::Bests::Beginner provides accessors for {Game#type} == "Beginner".
  class Beginner
    include Behaviors

    def score_arel = score_base_arel.for_beginner_type
    def bbbvps_arel = bbbvps_base_arel.for_beginner_type
    def efficiency_arel = efficiency_base_arel.for_beginner_type
  end

  # Game::Bests::Intermediate provides accessors for {Game#type} ==
  # "Intermediate".
  class Intermediate
    include Behaviors

    def score_arel = score_base_arel.for_intermediate_type
    def bbbvps_arel = bbbvps_base_arel.for_intermediate_type
    def efficiency_arel = efficiency_base_arel.for_intermediate_type
  end

  # Game::Bests::Expert provides accessors for {Game#type} == "Expert".
  class Expert
    include Behaviors

    def score_arel = score_base_arel.for_expert_type
    def bbbvps_arel = bbbvps_base_arel.for_expert_type
    def efficiency_arel = efficiency_base_arel.for_expert_type
  end
end
