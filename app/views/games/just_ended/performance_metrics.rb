# frozen_string_literal: true

# :reek:InstanceVariableAssumption

# Games::JustEnded::PerformanceMetrics is a specialized version of
# {Games::Past::PerformanceMetrics} that adds "Personal Best" indicators to each
# of the tracked metrics:
# - Score,
# - 3BV/s, and
# - Efficiency.
#
# We're able to render *Personal* Bests because we're using a lazy-loaded Turbo
# frame to render `games/just_ended/<active_participants|observer>/footer` for
# each individual viewer ({User}).
#
# That said, it should be noted that this also means a whole slew of queries
# will come in--at least 3 for every active participant, for this feature
# alone--all at once, on {Game} end.
class Games::JustEnded::PerformanceMetrics < Games::Past::PerformanceMetrics
  PERSONAL_BEST_CONTAINER_CSS = "text-yellow-400 dark:text-yellow-300"

  def initialize(user:, game:)
    @user = user
    super(game:)
  end

  def score = build_for(Score, value: super)
  def bbbvps = build_for(Bbbvps, value: super)
  def efficiency = build_for(Efficiency, value: super)

  private

  attr_reader :user

  def build_for(type, value:)
    if bestable?
      type.new(user_bests:, game:, value:)
    else
      NullPerformanceMetric.new(value:)
    end
  end

  # :reek:NilCheck
  def bestable?
    return @bestable unless @bestable.nil?

    @bestable = bestable_game_type? && user_was_an_active_participant?
  end

  def bestable_game_type? = game.bestable_type?
  def user_was_an_active_participant? = user.active_participant_in?(game:)

  def user_bests
    @user_bests ||= game.user_bests(user:)
  end

  # :reek:ModuleInitialize

  # Games::JustEnded::PerformanceMetrics::Behaviors ...
  module Behaviors
    attr_reader :value

    def initialize(user_bests:, game:, value:) # rubocop:disable Lint/MissingSuper
      @user_bests = user_bests
      @game = game
      @value = value
    end

    def personal_best? = raise(NotImplementedError)

    def css
      PERSONAL_BEST_CONTAINER_CSS if personal_best?
    end

    private

    attr_reader :user_bests,
                :game
  end

  # Games::JustEnded::PerformanceMetrics::Score provides accessors for the
  # "Score" performance metric.
  class Score
    include Behaviors

    def personal_best? = user_bests.score?(game:)
  end

  # Games::JustEnded::PerformanceMetrics::Bbbvps provides accessors for the
  # "3BV/s" performance metric.
  class Bbbvps
    include Behaviors

    def personal_best? = user_bests.bbbvps?(game:)
  end

  # Games::JustEnded::PerformanceMetrics::Efficiency provides accessors for
  # the "Efficiency" performance metric.
  class Efficiency
    include Behaviors

    def personal_best? = user_bests.efficiency?(game:)
  end

  # Games::JustEnded::PerformanceMetrics::NullPerformanceMetric is a stand-in
  # for when {Game#bestable_type?} == false. It simply passes through {#value}
  # while denying any personal bests.
  class NullPerformanceMetric
    attr_reader :value

    def initialize(value:) = @value = value
    def personal_best? = false
    def css = nil
  end
end
