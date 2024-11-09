# frozen_string_literal: true

# Users::Bests represents the "Bests" (top scores, 3BV/s's, efficiencies)
# section on {User} Show pages.
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

  def score = Score.new(user:)
  def bbbvps = BBBVPS.new(user:)
  def efficiency = Efficiency.new(user:)

  private

  attr_reader :user

  def completed_games_count = user.completed_games_count

  # :reek:ModuleInitialize

  # Users::Bests::Behaviors
  module Behaviors
    include Games::Past::ActiveLinkBehaviors

    def initialize(user:)
      @user = user
    end

    private

    attr_reader :user

    def user_bests = @user_bests ||= user.bests

    def url_for(game)
      Router.user_game_path(user, game) if game
    end
  end

  # Users::Bests::Score
  class Score
    include Behaviors

    def beginner_score? = !!_beginner
    def beginner_score = score(_beginner)
    def beginner_score_url = url_for(_beginner)

    def intermediate_score? = !!_intermediate
    def intermediate_score = score(_intermediate)
    def intermediate_score_url = url_for(_intermediate)

    def expert_score? = !!_expert
    def expert_score = score(_expert)
    def expert_score_url = url_for(_expert)

    private

    def score(game)
      View.display(game&.score) { |value| View.round(value) }
    end

    def _beginner = @_beginner ||= user_bests.beginner_score
    def _intermediate = @_intermediate ||= user_bests.intermediate_score
    def _expert = @_expert ||= user_bests.expert_score
  end

  # Users::Bests::BBBVPS
  class BBBVPS
    include Behaviors

    def beginner_bbbvps? = !!_beginner
    def beginner_bbbvps = bbbvps(_beginner)
    def beginner_bbbvps_url = url_for(_beginner)

    def intermediate_bbbvps? = !!_intermediate
    def intermediate_bbbvps = bbbvps(_intermediate)
    def intermediate_bbbvps_url = url_for(_intermediate)

    def expert_bbbvps? = !!_expert
    def expert_bbbvps = bbbvps(_expert)
    def expert_bbbvps_url = url_for(_expert)

    private

    def bbbvps(game)
      View.display(game&.bbbvps) { |value| View.round(value) }
    end

    def _beginner = @_beginner ||= user_bests.beginner_bbbvps
    def _intermediate = @_intermediate ||= user_bests.intermediate_bbbvps
    def _expert = @_expert ||= user_bests.expert_bbbvps
  end

  # Users::Bests::Efficiency
  class Efficiency
    include Behaviors

    def beginner_efficiency? = !!_beginner
    def beginner_efficiency = efficiency(_beginner)
    def beginner_efficiency_url = url_for(_beginner)

    def intermediate_efficiency? = !!_intermediate
    def intermediate_efficiency = efficiency(_intermediate)
    def intermediate_efficiency_url = url_for(_intermediate)

    def expert_efficiency? = !!_expert
    def expert_efficiency = efficiency(_expert)
    def expert_efficiency_url = url_for(_expert)

    private

    def efficiency(game)
      View.display(game&.efficiency) { |value| View.percentage(value * 100.0) }
    end

    def _beginner = @_beginner ||= user_bests.beginner_efficiency
    def _intermediate = @_intermediate ||= user_bests.intermediate_efficiency
    def _expert = @_expert ||= user_bests.expert_efficiency
  end
end
