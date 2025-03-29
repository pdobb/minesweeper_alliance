# frozen_string_literal: true

# User::Bests provides methods for finding the "Best Games" (top scoring, lowest
# 3BV/s, highest efficiency) that a {User} has actively participated in. And/or
# identifying *if* the given {Game} is a "Best Game".
#
# User::Bests are bucketed by {Game::Type::BESTABLE_TYPES}, accessed via
# corresponding method names.
class User::Bests
  def initialize(user)
    @user = user
  end

  def for_type(type) = public_send(type.downcase)

  def beginner = @beginner ||= Beginner.new(user:)
  def intermediate = @intermediate ||= Intermediate.new(user:)
  def expert = @expert ||= Expert.new(user:)

  private

  attr_reader :user

  # :reek:ModuleInitialize

  # User::Bests::Behaviors defines common behaviors for the various types
  # herein.
  module Behaviors
    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def score = score_arel.take
    def bbbvps = bbbvps_arel.take
    def efficiency = efficiency_arel.take

    # Determine if the passed in {Game} matches that of the {User}'s best
    # performance for each category.

    def score?(game:) = game && score_arel.pick(:id) == game.id
    def bbbvps?(game:) = game && bbbvps_arel.pick(:id) == game.id
    def efficiency?(game:) = game && efficiency_arel.pick(:id) == game.id

    private

    def base_arel = user.actively_participated_in_games
    def score_base_arel = base_arel.by_score_asc.by_least_recent
    def bbbvps_base_arel = base_arel.by_bbbvps_desc.by_least_recent
    def efficiency_base_arel = base_arel.by_efficiency_desc.by_least_recent
  end

  # User::Bests::Beginner provides accessors for {Game#type} == "Beginner".
  class Beginner
    include Behaviors

    private

    def score_arel = score_base_arel.for_beginner_type
    def bbbvps_arel = bbbvps_base_arel.for_beginner_type
    def efficiency_arel = efficiency_base_arel.for_beginner_type
  end

  # User::Bests::Intermediate provides accessors for
  # {Game#type} == "Intermediate".
  class Intermediate
    include Behaviors

    private

    def score_arel = score_base_arel.for_intermediate_type
    def bbbvps_arel = bbbvps_base_arel.for_intermediate_type
    def efficiency_arel = efficiency_base_arel.for_intermediate_type
  end

  # User::Bests::Expert provides accessors for {Game#type} == "Expert".
  class Expert
    include Behaviors

    private

    def score_arel = score_base_arel.for_expert_type
    def bbbvps_arel = bbbvps_base_arel.for_expert_type
    def efficiency_arel = efficiency_base_arel.for_expert_type
  end
end
