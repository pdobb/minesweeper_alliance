# frozen_string_literal: true

# :reek:ModuleInitialize

# Games::Past::PerformanceMetrics::Behaviors defines the core behaviors of the
# "Bestable" types (Score, 3BV/s, Efficiency).
module Games::Past::PerformanceMetrics::Behaviors
  extend ActiveSupport::Concern

  BEST_CONTAINER_CSS = "text-yellow-400 dark:text-yellow-300"
  private_constant :BEST_CONTAINER_CSS

  attr_reader :value

  def initialize(game:, user:, value:)
    @game = game
    @user = user
    @value = value
  end

  def container_css
    BEST_CONTAINER_CSS if best?
  end

  def best? = best.present?

  def partial_path
    "games/past/performance_metrics/#{type_name}_best"
  end

  def to_s = value.to_s

  private

  attr_reader :game,
              :user

  def type_name
    if best.for_the_alliance? && user.active_participant_in?(game:)
      # If the User was a participant and this was an Alliance Best then it must
      # also be a Personal Best. No need to go check.
      "alliance_and_personal"
    else
      best.type_name
    end
  end

  def best
    @best ||= begin
      base_class = Games::Past::PerformanceMetrics
      context = BestContext.new(game:, user:)

      base_class::AllianceBest.new(context:, query_method:).presence ||
        base_class::PersonalBest.new(context:, query_method:).presence ||
        NullBest.new(context:)
    end
  end

  # Games::Past::PerformanceMetrics::Behaviors::BestContext services the needs
  # of the "Best" types ("AllianceBest", "PersonalBest").
  class BestContext
    attr_reader :game,
                :user

    def initialize(game:, user:)
      @game = game
      @user = user
    end

    def game_bests
      @game_bests ||= Game::Bests.build_for(game:)
    end

    def user_bests
      @user_bests ||= game.user_bests(user:)
    end
  end

  # Games::Past::PerformanceMetrics::Behaviors::NullBest stands in when the
  # associated {Game} is not on of the "Bests" ("Alliance Best" nor a
  # "Personal Best").
  class NullBest
    def initialize(*) = nil
    def present? = false
  end
end
