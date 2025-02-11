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
        "COUNT(participant_transactions.id) AS active_participation_count",
        "MAX(participant_transactions.created_at) AS most_recent_transaction").
        joins(:active_participant_transactions).
        group("users.id").
        order(active_participation_count: :desc).
        order(:most_recent_transaction)
    end

    def limit = Metrics::Show::TOP_RECORDS_LIMIT

    # Metrics::Show::Games::Listing
    class Listing
      include WrapMethodBehaviors

      def initialize(user)
        @user = user
      end

      def active_participation_count = user.active_participation_count

      def name = username || mms_id
      def user_url = Router.user_path(user)

      def title? = username?
      def title = user.display_name

      private

      attr_reader :user

      def username? = user.username?
      def username = user.username
      def mms_id = user.mms_id
    end

    # Metrics::Show::Games::NullListing implements the Null Pattern for
    # {Metrics::Show::Games::Listing} view models.
    class NullListing
      def active_participation_count = View.no_value_indicator_tag
      def present? = false
      def name = View.no_value_indicator_tag
      def user_url = nil
      def title? = false
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
