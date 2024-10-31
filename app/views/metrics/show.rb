# frozen_string_literal: true

# Metrics::Show is a View Model for displaying the Metrics Show page.
class Metrics::Show
  TOP_RECORDS_LIMIT = 3
  NO_VALUE_INDICATOR = "—"

  def cache_key
    [:games_count, Game.for_status_alliance_wins.size]
  end

  def top_games_by_type
    [
      BeginnerGames.new,
      IntermediateGames.new,
      ExpertGames.new,
    ]
  end

  def no_value_indicator = NO_VALUE_INDICATOR

  # Metrics::Show::Games is an abstract base class that holds methods common to
  # the Metrics::Show::<Type>Games models.
  class Games
    include AbstractBaseClassBehaviors

    as_abstract_class

    def type = raise(NotImplementedError)
    def limit = TOP_RECORDS_LIMIT
    def listings = @listings ||= Listing.wrap(arel)

    private

    def arel = raise(NotImplementedError)

    def base_arel
      Game.for_status_alliance_wins.by_score_asc.limit(TOP_RECORDS_LIMIT)
    end

    # Metrics::Show::Games::Listing
    class Listing
      include WrapMethodBehaviors

      def initialize(game)
        @game = game
      end

      def game_score = game.score
      def players_count = game.users.size

      def game_url
        router.game_path(game)
      end

      private

      attr_reader :game

      def router = RailsRouter.instance
    end
  end

  # Metrics::Show::BeginnerGames
  class BeginnerGames < Metrics::Show::Games
    def type = Game::BEGINNER_TYPE
    def arel = base_arel.for_beginner_type
  end

  # Metrics::Show::IntermediateGames
  class IntermediateGames < Metrics::Show::Games
    def type = Game::INTERMEDIATE_TYPE
    def arel = base_arel.for_intermediate_type
  end

  # Metrics::Show::ExpertGames
  class ExpertGames < Metrics::Show::Games
    def type = Game::EXPERT_TYPE
    def arel = base_arel.for_expert_type
  end
end
