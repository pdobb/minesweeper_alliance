# frozen_string_literal: true

# Users::Show is a View Model for displaying the User Show page.
class Users::Show
  DEFAULT_PRECISION = 2
  NO_VALUE_INDICATOR = "—"

  def initialize(user:)
    @user = user
  end

  def cache_key
    [user, service_record.completed_games_count]
  end

  def display_name = user.display_name
  def enlistment_date = I18n.l(user.created_at.to_date)

  def service_record
    @service_record ||= ServiceRecord.new(user:)
  end

  def bests
    Bests.new(user:)
  end

  def games
    Games.new(
      base_arel: user.games.for_game_over_statuses.by_most_recently_ended,
      user:)
  end

  private

  attr_reader :user

  # Users::Show::ServiceRecord
  class ServiceRecord
    def initialize(user:)
      @user = user
    end

    def games_count = delimit(completed_games_count)

    def completed_games_count
      @completed_games_count ||= games_arel.for_game_over_statuses.size
    end

    def winning_games_count
      return 0 if _winning_games_count.zero?

      "#{_winning_games_count} (#{winning_games_percentage})"
    end

    def losing_games_count
      return 0 if _losing_games_count.zero?

      "#{_losing_games_count} (#{losing_games_percentage})"
    end

    def reveals_count = delimit(_reveals_count)
    def chords_count = delimit(_chords_count)
    def flags_count = delimit(_flags_count)
    def unflags_count = delimit(_unflags_count)
    def tripped_mines_count = delimit(_tripped_mines_count)

    private

    attr_reader :user

    def winning_games_percentage = percentage(winning_games_percent)
    def winning_games_percent = winning_games_ratio * 100.0
    def winning_games_ratio = _winning_games_count / completed_games_count.to_f

    def _winning_games_count
      @_winning_games_count ||= games_arel.for_status_alliance_wins.size
    end

    def losing_games_percentage = percentage(losing_games_percent)
    def losing_games_percent = losing_games_ratio * 100.0
    def losing_games_ratio = _losing_games_count / completed_games_count.to_f

    def _losing_games_count
      @_losing_games_count ||= games_arel.for_status_mines_win.size
    end

    def _reveals_count = cell_reveal_transactions.size
    def cell_reveal_transactions = user.cell_reveal_transactions

    def _chords_count = cell_chord_transactions.size
    def cell_chord_transactions = user.cell_chord_transactions

    def _flags_count = cell_flag_transactions.size
    def cell_flag_transactions = user.cell_flag_transactions

    def _unflags_count = cell_unflag_transactions.size
    def cell_unflag_transactions = user.cell_unflag_transactions

    def _tripped_mines_count = user.revealed_cells.is_mine.size

    def games_arel = user.games

    def percentage(value, precision: DEFAULT_PRECISION)
      helpers.number_to_percentage(value, precision:)
    end

    def delimit(value)
      helpers.number_with_delimiter(value)
    end

    def helpers = ActionController::Base.helpers
  end

  # Users::Show::Bests
  class Bests
    def initialize(user:)
      @user = user
    end

    def score = Score.new(user:)
    def bbbvps = BBBVPS.new(user:)
    def efficiency = Efficiency.new(user:)

    private

    attr_reader :user

    # :reek:ModuleInitialize

    # Users::Show::Bests::Behaviors
    module Behaviors
      def initialize(user:)
        @user = user
      end

      private

      attr_reader :user

      def user_bests = @user_bests ||= user.bests

      def url_for(game, router: RailsRouter.instance)
        router.user_game_path(user, game) if game
      end

      def valuify(value)
        value ? yield(value) : NO_VALUE_INDICATOR
      end

      def helpers = ActionController::Base.helpers
    end

    # Users::Show::Bests::Score
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
        valuify(game&.score) { |score| score.round(DEFAULT_PRECISION) }
      end

      def _beginner = @_beginner ||= user_bests.beginner_score
      def _intermediate = @_intermediate ||= user_bests.intermediate_score
      def _expert = @_expert ||= user_bests.expert_score
    end

    # Users::Show::Bests::BBBVPS
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
        valuify(game&.bbbvps) { |bbbvps| bbbvps.round(DEFAULT_PRECISION) }
      end

      def _beginner = @_beginner ||= user_bests.beginner_bbbvps
      def _intermediate = @_intermediate ||= user_bests.intermediate_bbbvps
      def _expert = @_expert ||= user_bests.expert_bbbvps
    end

    # Users::Show::Bests::Efficiency
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
        valuify(game&.efficiency) { |efficiency|
          percentage(efficiency * 100.0)
        }
      end

      def _beginner = @_beginner ||= user_bests.beginner_efficiency
      def _intermediate = @_intermediate ||= user_bests.intermediate_efficiency
      def _expert = @_expert ||= user_bests.expert_efficiency

      def percentage(value, precision: DEFAULT_PRECISION)
        helpers.number_to_percentage(value, precision:)
      end
    end
  end

  # Users::Show::Games is a View Model for displaying a user's past {Game}s on
  # the User Show page.
  class Games
    def initialize(base_arel:, user:)
      @base_arel = base_arel
      @user = user
    end

    def engagement_tally
      EngagementTally.new(user:, base_arel:)
    end

    def any_listings? = arel.any?

    def listings_grouped_by_date
      games_grouped_by_ended_at.
        transform_keys! { |date|
          ::Games::Index::ListingsDate.new(date, base_arel: arel)
        }. # rubocop:disable Style/MultilineBlockChain
        transform_values! { |games| Listing.wrap(games, user:) }
    end

    private

    attr_reader :base_arel,
                :user

    def arel = base_arel

    def games_grouped_by_ended_at
      arel.group_by { |game| game.ended_at.to_date }
    end

    # Users::Show::Games::EngagementTally
    class EngagementTally
      include ::Games::EngagementTallyBehaviors

      def initialize(user:, base_arel:)
        @user = user
        @base_arel = base_arel
      end

      private

      attr_reader :user,
                  :base_arel

      def start_at = user.created_at
    end

    # Users::Show::Games::Listing
    class Listing < ::Games::Index::Listing
      def initialize(model, user:)
        super(model)
        @user = user
      end

      def game_url(router = RailsRouter.instance)
        router.user_game_path(user, to_model)
      end

      private

      attr_reader :user
    end
  end
end
