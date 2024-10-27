# frozen_string_literal: true

# Records::Index is a View Model for displaying the Records Index page.
class Records::Index
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

  # Records::Index::TopGames
  class TopGames
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

    # Records::Index::TopGames::Listing
    class Listing
      include WrapMethodBehaviors

      def initialize(model)
        @model = model
      end

      def game_score = to_model.score
      def players_count = to_model.users.size

      def game_url(router = RailsRouter.instance)
        router.game_path(to_model)
      end

      private

      def to_model = @model
    end
  end

  # Records::Index::BeginnerGames
  class BeginnerGames < Records::Index::TopGames
    def type = Board::Settings::BEGINNER
    def arel = base_arel.for_beginner_type
  end

  # Records::Index::IntermediateGames
  class IntermediateGames < Records::Index::TopGames
    def type = Board::Settings::INTERMEDIATE
    def arel = base_arel.for_intermediate_type
  end

  # Records::Index::ExpertGames
  class ExpertGames < Records::Index::TopGames
    def type = Board::Settings::EXPERT
    def arel = base_arel.for_expert_type
  end
end
