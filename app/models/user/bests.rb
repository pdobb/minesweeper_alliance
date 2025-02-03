# frozen_string_literal: true

# User::Bests provides methods for finding the "Best Games" (top scoring, lowest
# 3BV/s, highest efficiency) that a {User} has actively participated in.
#
# User::Bests are bucketed by {Game::BESTABLE_TYPES}, accessed via corresponding
# method names.
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

    # Determine if the passed in {Game} matches that of the {User}'s best
    # performance for each category.

    def score?(game:) = game && score == game
    def bbbvps?(game:) = game && bbbvps == game
    def efficiency?(game:) = game && efficiency == game

    private

    def base_arel = user.actively_participated_in_games
    def score_arel = base_arel.by_score_asc
    def bbbvps_arel = base_arel.by_bbbvps_desc
    def efficiency_arel = base_arel.by_efficiency_desc
  end

  # User::Bests::Beginner provides accessors for {Game#type} == "Beginner".
  class Beginner
    include Behaviors

    def score = score_arel.for_beginner_type.take
    def bbbvps = bbbvps_arel.for_beginner_type.take
    def efficiency = efficiency_arel.for_beginner_type.take
  end

  # User::Bests::Intermediate provides accessors for {Game#type} ==
  # "Intermediate".
  class Intermediate
    include Behaviors

    def score = score_arel.for_intermediate_type.take
    def bbbvps = bbbvps_arel.for_intermediate_type.take
    def efficiency = efficiency_arel.for_intermediate_type.take
  end

  # User::Bests::Expert provides accessors for {Game#type} == "Expert".
  class Expert
    include Behaviors

    def score = score_arel.for_expert_type.take
    def bbbvps = bbbvps_arel.for_expert_type.take
    def efficiency = efficiency_arel.for_expert_type.take
  end
end
