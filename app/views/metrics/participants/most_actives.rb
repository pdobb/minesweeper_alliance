# frozen_string_literal: true

# Metrics::Participants::MostActives represents top-lists of the most active
# {User}s per each {Game#type} (Beginner, Intermediate, Expert).
class Metrics::Participants::MostActives
  def self.per_type
    [
      Beginner.new,
      Intermediate.new,
      Expert.new,
    ]
  end

  # Metrics::Participants::MostActives::BaseType is an abstract base class that
  # holds methods common to the Metrics::Show::Participants::MostActives::<Type>
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
      User.select(
        "users.*",
        "COUNT(participant_transactions.id) AS active_participation_count").
        group("users.id").
        joins(:active_participant_transactions).
        order(active_participation_count: :desc)
    end

    def limit = Metrics::Show::TOP_RECORDS_LIMIT

    # Metrics::Show::Games::Listing
    class Listing
      include WrapMethodBehaviors

      def initialize(user)
        @user = user
      end

      def table_cell_css = nil

      def display_name = user.display_name
      def username = user.username
      def user_url = Router.user_path(user)
      def active_participation_count = user.active_participation_count

      private

      attr_reader :user

      def _score = user.score
    end

    # Metrics::Show::Games::NullListing implements the Null Pattern for
    # {Metrics::Show::Games::Listing} view models.
    class NullListing
      def present? = false
      def table_cell_css = "text-dim-lg"
      def display_name = nil
      def username = View.no_value_indicator
      def user_url = nil
      def active_participation_count = View.no_value_indicator
    end
  end

  # Metrics::Show::Participants::MostActives::Beginner
  class Beginner < Metrics::Participants::MostActives::BaseType
    def type = Game::BEGINNER_TYPE

    private

    def arel
      base_arel.merge(
        ParticipantTransaction.joins(:game).merge(Game.for_beginner_type))
    end
  end

  # Metrics::Show::Participants::MostActives::Intermediate
  class Intermediate < Metrics::Participants::MostActives::BaseType
    def type = Game::INTERMEDIATE_TYPE

    private

    def arel
      base_arel.merge(
        ParticipantTransaction.joins(:game).merge(Game.for_intermediate_type))
    end
  end

  # Metrics::Show::Participants::MostActives::Expert
  class Expert < Metrics::Participants::MostActives::BaseType
    def type = Game::EXPERT_TYPE

    private

    def arel
      base_arel.merge(
        ParticipantTransaction.joins(:game).merge(Game.for_expert_type))
    end
  end
end
