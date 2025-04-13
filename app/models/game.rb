# frozen_string_literal: true

# :reek:TooManyConstants
# :reek:TooManyMethods

# Game represents a game of Minesweeper Alliance. Game play is kept as close to
# that of the original Microsoft Minesweeper game as possible, while adding a
# real-time, collaborative multiplayer element to it.
#
# Game is the top-most model in the object graph that's driving the overall
# gameplay flow--from new game creation to game end. The current Game "state"
# is stored by {Game#status}, and is described by the lifecycle states:
# - "Standing By",
# - "Sweep in Progress", and either
# - "Alliance Wins" or "Mines Win"
#
# Typical flow for Game creation/start is:
# 1. Build a new Game (`Game::Factory.build_for(settings: <Board::Settings>)`),
# 2. Which builds an associated {Board} (storing off the given {Board::Settings}
#    object into {Board#settings} as a serialized Hash).
# 3. Generate an associated 1-dimensional Array of {Cell}s of length
#    {Board#width} * {Board#height}--filling in {Cell#coordinates} for each,
#    based on its Array index (see {Board::Generate#build_coordinates_for}).
# 4. Atomically save all of the above to the database, while also setting the
#    lifecycle state of the Game ({Game#status}) to "Standing By" (i.e. awaiting
#    the first {Cell#reveal} of the Game).
#
# Later, when a {User} clicks to reveal a {Cell}, as the opening "move" of the
# game:
#  1. Randomly mark {Cell#mine} = `true` from among the associated Array of
#     {Board#cells}.
#    - Note: We ensure that the first-revealed Cell of the game (a.k.a. the
#      "Seed Cell") is excluded from the set so that the first {Cell#reveal} of
#      the Game is, in effect, always safe.º
#    - The number of mines to be placed comes from the stored {Board#settings}.
#  2. Start the Game (i.e. transition to lifecycle state: "Sweep in Progress").
#  3. Reveal the first-clicked-on {Cell}, following the general rules of
#     Minesweeper gameplay from there.
#
#  º EXCEPTION: In the case of a "Pattern" Game board, mines are specifically
#    placed after step 4 in the "Typical flow for Game creation/start", above.
#    Which means that the first {Cell#reveal} of the Game for a "Pattern" Game
#    board is *not* safe and *can* end the Game in defeat, straight away.
#
# @attr status [String] The current Game status / life-cycle state.
# @attr type [String] The preset or Game type used to generate this Game's
#   {Board} / {Grid} of {Cell}s.
#   Note: This attribute/column is *not* used for STI.
# @attr started_at [DateTime] When this Game started. i.e. transitioned from
#   {#status} "Standing By" to "Sweep in Progress". This is a cached version of
#   the associated {GameStartTransaction#created_at} value.
# @attr ended_at [DateTime] When this Game ended. i.e. transitioned from
#   {#status} "Sweep in Progress" to either "Alliance Wins" or "Mines Win".
#   This is a cached version of the associated {GameEndTransaction#created_at}
#   value.
# @attr score [Integer] The play-time in seconds of a victorious Game. Maxes out
#   at {MAX_SCORE} (999).
# @attr bbbv [Integer] The 3BV value for the associated, solved {Board}.
# @attr bbbvps [Float] The 3BV/s rating of a solved {Board}.
# @attr efficiency [Float] The ratio of actual clicks vs necessary clicks (3BV)
#   used to solve the associated {Board}.
# @attr spam [Boolean] Designates that this Game was not a valid attempt at
#   completing the Game. Spam Games are excluded from tallies, etc.
# @attr active_participants_count [Integer] A counter-cache of
#   `game.active_participant_transactions.count`. Maintained by
#   {ParticipantTransaction.create_active_between} and
#   {ParticipantTransaction.activate_between}.
class Game < ApplicationRecord # rubocop:disable Metrics/ClassLength
  self.inheritance_column = nil
  self.implicit_order_column = "created_at"

  RECENTLY_ENDED_DURATION = 3.minutes

  ALL_TYPES = [
    BEGINNER_TYPE = "Beginner",
    INTERMEDIATE_TYPE = "Intermediate",
    EXPERT_TYPE = "Expert",
    CUSTOM_TYPE = "Custom",
    PATTERN_TYPE = "Pattern",
  ].freeze

  MAX_SCORE = 999

  include ConsoleBehaviors
  include Statusable::HasStatuses

  has_one :board, dependent: :delete, class_name: "::Board"
  validates_associated :board, on: :create

  has_many :cells, through: :board

  # Users that joined in on this Game--in any fashion.
  # (Whether or not they were active participants in this Game).
  has_many :participant_transactions, dependent: :restrict_with_exception
  has_many :users, through: :participant_transactions

  # Users that joined in on, but never actively participated in this Game.
  has_many :passive_participant_transactions,
           -> { is_passive },
           inverse_of: :game,
           class_name: "ParticipantTransaction"
  has_many :observers,
           through: :passive_participant_transactions,
           source: :user

  # Users that actively participated in this Game.
  has_many :active_participant_transactions,
           -> { is_active },
           inverse_of: :game,
           class_name: "ParticipantTransaction"
  has_many :active_participants,
           through: :active_participant_transactions,
           source: :user

  has_many :game_transactions, dependent: :delete_all
  has_one :game_create_transaction
  has_one :game_start_transaction
  has_one :game_end_transaction

  has_many :cell_transactions, through: :cells
  has_many :cell_reveal_transactions, through: :cells
  has_many :cell_chord_transactions, through: :cells
  has_many :cell_flag_transactions, through: :cells
  has_many :cell_unflag_transactions, through: :cells

  has_statuses([
    "Standing By",
    "Sweep in Progress",
    "Alliance Wins",
    "Mines Win",
  ])

  scope :is_spam, -> { where(spam: true) }
  scope :is_not_spam, -> { where(spam: false) }

  scope :for_beginner_type, -> { for_type(BEGINNER_TYPE) }
  scope :for_intermediate_type, -> { for_type(INTERMEDIATE_TYPE) }
  scope :for_expert_type, -> { for_type(EXPERT_TYPE) }
  scope :for_bestable_type, -> { where(type: Game::Type::BESTABLE_TYPES) }
  scope :for_type, ->(type) { where(type:) }

  scope :for_bests_of_type_beginner, -> { for_bests_of_type(BEGINNER_TYPE) }
  scope :for_bests_of_type_intermediate,
        -> { for_bests_of_type(INTERMEDIATE_TYPE) }
  scope :for_bests_of_type_expert, -> { for_bests_of_type(EXPERT_TYPE) }
  scope :for_bests_of_type, ->(type) {
    # rubocop:disable Layout/LineLength
    subquery =
      select(
        "games.*",
        "ROW_NUMBER() OVER (PARTITION BY type ORDER BY score ASC) AS rn_score",
        "ROW_NUMBER() OVER (PARTITION BY type ORDER BY bbbvps DESC) AS rn_bbbvps",
        "ROW_NUMBER() OVER (PARTITION BY type ORDER BY efficiency DESC) AS rn_efficiency")
        .where.not(score: nil).where.not(bbbvps: nil).where.not(efficiency: nil)
        .for_type(type)
    # rubocop:enable Layout/LineLength

    from(subquery, :games)
      .where("rn_score = 1 OR rn_bbbvps = 1 OR rn_efficiency = 1")
  }

  scope :for_current_or_recently_ended, ->(duration = RECENTLY_ENDED_DURATION) {
    for_game_on_statuses.or(for_recently_ended(duration))
  }
  scope :for_recently_ended, ->(duration = RECENTLY_ENDED_DURATION) {
    for_game_over_statuses.for_ended_at(duration.ago..)
  }
  scope :for_game_on_statuses,
        -> { for_status([status_standing_by, status_sweep_in_progress]) }
  scope :for_game_over_statuses,
        -> { for_status([status_alliance_wins, status_mines_win]) }
  scope :for_ended_at, ->(ended_at) { where(ended_at:) }
  scope :for_end_date, ->(date, time_zone = Time.zone.tzinfo.name) {
    where(
      Arel.sql("DATE(ended_at AT TIME ZONE :time_zone) = :date"),
      time_zone:,
      date:)
  }
  scope :for_end_date_on_or_before,
        ->(date, time_zone = Time.zone.tzinfo.name) {
          where(
            Arel.sql("DATE(ended_at AT TIME ZONE :time_zone) <= :date"),
            time_zone:,
            date:)
        }

  scope :by_most_recently_ended, -> { order(ended_at: :desc) }
  scope :by_score_asc, -> { where.not(score: nil).order(score: :asc) }
  scope :by_bbbvps_desc, -> { where.not(bbbvps: nil).order(bbbvps: :desc) }
  scope :by_efficiency_desc, -> {
    where.not(efficiency: nil).order(efficiency: :desc)
  }

  validates :type, presence: true

  def self.display_id_width
    @display_id_width ||= [largest_id.digits.size, 4].max
  end

  def self.largest_id = @largest_id ||= by_most_recent.pick(:id)

  def self.prune_fleet_tracker
    FleetTracker.purge_deeply_expired_entries! if last&.ended_a_while_ago?
  end

  def display_id = "##{id.to_s.rjust(self.class.display_id_width, "0")}"

  # :reek:TooManyStatements

  def start(seed_cell:, user:)
    return self unless status_standing_by?

    transaction do
      GameStartTransaction.create_between(user:, game: self)
      board.place_mines(seed_cell:)
      set_status_sweep_in_progress!
    end

    self
  end

  def end_in_victory(user:)
    end_game(user:) {
      set_status_alliance_wins!
      Stats::Calculate.(self)
    }
  end

  def end_in_defeat(user:)
    end_game(user:) {
      set_status_mines_win!
    }
  end

  def update_started_at(time:)
    touch(:started_at, time:)
    self.just_started = true
  end

  def update_ended_at(time:)
    touch(:ended_at, time:)
    self.just_ended = true
  end

  def on?
    status?([status_standing_by, status_sweep_in_progress])
  end

  def over?
    !on?
  end

  def just_started? = !!just_started
  def just_ended? = !!just_ended
  def ended_in_victory? = status_alliance_wins?
  def ended_in_defeat? = status_mines_win?

  def ended_a_while_ago?(minutes: FleetTracker::DEEP_EXPIRATION_MINUTES)
    return false unless ended_at?

    ended_at + minutes <= Time.current
  end

  def board_settings = board&.settings

  def best_categories
    @best_categories ||= Game::Bests.build_for(game: self).categories
  end

  def user_bests(user:)
    Game::Type.validate_bestable(type)

    user.bests.for_type(type)
  end

  def many_active_participants? = active_participants_count > 1

  private

  attr_accessor :just_started,
                :just_ended

  def end_game(user:)
    return self if over?

    transaction do
      GameEndTransaction.create_between(user:, game: self)
      yield
    end

    self
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      { self => board.introspect }
    end

    private

    def inspect_identification = identify

    def inspect_flags(scope:)
      scope.join_flags([
        type,
        status,
      ])
    end

    def inspect_info(scope:)
      return unless score || bbbv || efficiency

      scope.join_info([
        "Score: #{score.inspect}",
        "3BV: #{bbbv.inspect}",
        "Efficiency: #{efficiency.inspect}",
      ])
    end

    def inspect_issues
      "SPAM" if spam?
    end

    def inspect_name = display_id
  end

  # Game::Console acts like a {Game} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def render
      puts(inspect)
      board.render
    end

    def reset
      do_reset {
        set_status_sweep_in_progress! if over?
        game_start_transaction.update(created_at: Time.current)
        touch(:started_at, time: game_start_transaction.created_at)
        board.reset
      }
    end

    # Like {#reset} but also resets status to "Standing By" and resets mines on
    # the {Board}.
    def reset!
      do_reset {
        game_start_transaction&.delete
        update(started_at: nil)
        set_status_standing_by!
        board.reset!
      }
    end

    def mark_as_spam = update_column(:spam, true)
    def unmark_as_spam = update_column(:spam, false)

    private

    # :reek:TooManyStatements
    def do_reset
      check_for_current_game

      transaction do
        update!(
          ended_at: nil,
          score: nil,
          bbbv: nil,
          bbbvps: nil,
          efficiency: nil)

        game_end_transaction&.delete
        CellTransaction.for_id(cell_transaction_ids).delete_all

        yield
      end

      WarRoomChannel.broadcast_refresh

      self
    end

    def check_for_current_game
      current_game = Game::Current::Find.call

      if current_game && current_game != __model__
        raise(Error, "Can't reset a past Game while a current Game exists.")
      end

      current_game
    end
  end
end
