# frozen_string_literal: true

# Users::Show is a View Model for displaying the User Show page.
class Users::Show
  DEFAULT_PRECISION = 2
  NO_VALUE_INDICATOR = "—"

  def initialize(user:)
    @user = user
  end

  def cache_key
    [user, duty_log.completed_games_count]
  end

  def display_name = user.display_name
  def enlistment_date = I18n.l(user.created_at.to_date)

  def duty_log
    @duty_log ||= DutyLog.new(user:)
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

  # Users::Show::DutyLog
  class DutyLog
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

    def overall_score = score(_overall_score)
    def beginner_score = score(_beginner_score)
    def intermediate_score = score(_intermediate_score)
    def expert_score = score(_expert_score)

    def overall_bbbvps = bbbvps(_overall_bbbvps)
    def beginner_bbbvps = bbbvps(_beginner_bbbvps)
    def intermediate_bbbvps = bbbvps(_intermediate_bbbvps)
    def expert_bbbvps = bbbvps(_expert_bbbvps)

    def overall_efficiency = efficiency(_overall_efficiency)
    def beginner_efficiency = efficiency(_beginner_efficiency)
    def intermediate_efficiency = efficiency(_intermediate_efficiency)
    def expert_efficiency = efficiency(_expert_efficiency)

    private

    attr_reader :user

    def score(value)
      valuify(value) { |score| score.round(DEFAULT_PRECISION) }
    end

    def _beginner_score = _score(games_arel.for_beginner_type)
    def _intermediate_score = _score(games_arel.for_intermediate_type)
    def _expert_score = _score(games_arel.for_expert_type)
    def _score(arel) = arel.by_score_asc.pick(:score)

    def bbbvps(value)
      valuify(value) { |bbbvps| bbbvps.round(DEFAULT_PRECISION) }
    end

    def _beginner_bbbvps = _bbbvps(games_arel.for_beginner_type)
    def _intermediate_bbbvps = _bbbvps(games_arel.for_intermediate_type)
    def _expert_bbbvps = _bbbvps(games_arel.for_expert_type)
    def _bbbvps(arel) = arel.by_bbbvps_desc.pick(:bbbvps)

    def efficiency(value)
      valuify(value) { |efficiency| percentage(efficiency * 100.0) }
    end

    def _beginner_efficiency = _efficiency(games_arel.for_beginner_type)
    def _intermediate_efficiency = _efficiency(games_arel.for_intermediate_type)
    def _expert_efficiency = _efficiency(games_arel.for_expert_type)
    def _efficiency(arel) = arel.by_efficiency_desc.pick(:efficiency)

    def games_arel = user.games

    def valuify(value)
      value ? yield(value) : NO_VALUE_INDICATOR
    end

    def percentage(value, precision: DEFAULT_PRECISION)
      helpers.number_to_percentage(value, precision:)
    end

    def helpers = ActionController::Base.helpers
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
