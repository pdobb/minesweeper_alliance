# frozen_string_literal: true

# Metrics::Engagements::Bests represents top-lists of the best scoring {Game}s
# per each {Game#type} (Beginner, Intermediate, Expert).
class Metrics::Engagements::Bests
  TOP_RECORDS_LIMIT = 3

  def self.per_type
    [
      Beginner.new,
      Intermediate.new,
      Expert.new,
    ]
  end

  # Metrics::Engagements::Bests::BaseType is an abstract base class that
  # holds methods common to the Metrics::Show::Engagements::Bests::<Type>
  # models.
  class BaseType
    include AbstractBaseClassBehaviors

    as_abstract_class

    def type = raise(NotImplementedError)

    def listings
      @listings ||= Listing.wrap_upto(arel, limit:, fill: NullListing.new)
    end

    private

    def arel = raise(NotImplementedError)

    def base_arel
      Game.for_status_alliance_wins.by_score_asc.limit(limit)
    end

    def limit = TOP_RECORDS_LIMIT

    # Metrics::Show::Games::Listing
    class Listing
      include WrapMethodBehaviors
      include Games::Past::ActiveLinkBehaviors

      def initialize(game)
        @game = game
      end

      def table_cell_css = nil

      def game_score
        return Game::MAX_SCORE if _score >= Game::MAX_SCORE

        View.round(_score)
      end

      def fleet_size = game.users.size
      def game_url = Router.metrics_game_path(game)

      private

      attr_reader :game

      def _score = game.score
    end

    # Metrics::Show::Games::NullListing implements the Null Pattern for
    # {Metrics::Show::Games::Listing} view models.
    class NullListing
      def present? = false
      def table_cell_css = "text-dim-lg"
      def game_score = View.no_value_indicator
      def fleet_size = View.no_value_indicator
      def game_url = nil
      def link_action = nil
      def turbo_frame_name = nil
    end
  end

  # Metrics::Show::Engagements::Bests::Beginner
  class Beginner < Metrics::Engagements::Bests::BaseType
    def type = Game::BEGINNER_TYPE

    private

    def arel = base_arel.for_beginner_type
  end

  # Metrics::Show::Engagements::Bests::Intermediate
  class Intermediate < Metrics::Engagements::Bests::BaseType
    def type = Game::INTERMEDIATE_TYPE

    private

    def arel = base_arel.for_intermediate_type
  end

  # Metrics::Show::Engagements::Bests::Expert
  class Expert < Metrics::Engagements::Bests::BaseType
    def type = Game::EXPERT_TYPE

    private

    def arel = base_arel.for_expert_type
  end
end
