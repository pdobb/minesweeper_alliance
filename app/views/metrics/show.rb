# frozen_string_literal: true

# Metrics::Show is a View Model for displaying the Metrics Show page.
class Metrics::Show
  TOP_RECORDS_LIMIT = 3

  def engagements
    Engagements.new
  end

  # Metrics::Show::Engagements
  class Engagements
    def cache_key
      [:engagements, Game.for_status_alliance_wins.size]
    end

    def bests_per_type = Bests.per_type

    # Metrics::Show::Engagements::Bests
    class Bests
      def self.per_type
        [
          Beginner.new,
          Intermediate.new,
          Expert.new,
        ]
      end

      # Metrics::Show::Engagements::Bests::Base is an abstract base class that
      # holds methods common to the Metrics::Show::Engagements::Bests::<Type>
      # models.
      class Base
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

          def self.turbo_frame_name = :past_game_frame

          def initialize(game)
            @game = game
          end

          def table_cell_css = nil
          def game_score = View.round(game.score)
          def players_count = game.users.size
          def game_url = Router.metrics_game_path(game)

          def turbo_frame_name = self.class.turbo_frame_name

          private

          attr_reader :game
        end

        # Metrics::Show::Games::NullListing implements the NulL Pattern for
        # {Metrics::Show::Games::Listing} view models.
        class NullListing
          def present? = false
          def table_cell_css = "text-dim-lg"
          def game_score = View.no_value_indicator
          def players_count = View.no_value_indicator
          def game_url = nil
          def turbo_frame_name = nil
        end
      end

      # Metrics::Show::Engagements::Bests::Beginner
      class Beginner < Metrics::Show::Engagements::Bests::Base
        def type = Game::BEGINNER_TYPE

        private

        def arel = base_arel.for_beginner_type
      end

      # Metrics::Show::Engagements::Bests::Intermediate
      class Intermediate < Metrics::Show::Engagements::Bests::Base
        def type = Game::INTERMEDIATE_TYPE

        private

        def arel = base_arel.for_intermediate_type
      end

      # Metrics::Show::Engagements::Bests::Expert
      class Expert < Metrics::Show::Engagements::Bests::Base
        def type = Game::EXPERT_TYPE

        private

        def arel = base_arel.for_expert_type
      end
    end
  end
end
