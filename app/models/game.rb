# frozen_string_literal: true

# :reek:TooManyConstants
# :reek:TooManyMethods
# :reek:RepeatedConditional (#over?)

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
# 1. Build a new Game (`Game.build_for(settings: <Board::Settings>)`),
# 2. Which builds an associated {Board} (storing off the given {Board::Settings}
#    object into {Board#settings} as a serialized Hash).
# 3. Generate an associated 1-dimensional Array of {Cell}s of length
#    {Board#width} * {Board#height}--filling in {Cell#coordinates} for each,
#    based on its Array index (see {Board::Generate#build_coordinates_for}).
# 4. Atomically save all of the above to the database, while also setting the
#    lifecycle state of the Game ({Game#status}) to "Standing By" (i.e. awaiting
#    the first {Cell#reveal} of the Game).
#
# Later, when a player clicks to reveal a {Cell} in the first round of the
# game:
#  1. Randomly mark {Cell#mine} = `true` from among the associated Array of
#     {Board#cells}.
#    - Note: We ensure that the first-revealed Cell of the game (a.k.a. the
#      "Seed Cell") is excluded from this mine-placing randomization so that the
#      first {Cell#reveal} of the Game is, in effect, always safe.º
#    - The number of mines to be placed comes from the stored {Board#settings},
#      as may be expected.
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
class Game < ApplicationRecord # rubocop:disable Metrics/ClassLength
  self.inheritance_column = nil
  self.implicit_order_column = "created_at"

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

  has_one :board, dependent: :delete
  validates_associated :board, on: :create

  has_many :cells, through: :board

  has_many :game_transactions, dependent: :delete_all
  has_one :game_create_transaction
  has_many :game_join_transactions
  has_one :game_start_transaction
  has_one :game_end_transaction

  has_many :cell_transactions, through: :cells
  has_many :cell_reveal_transactions, through: :cells
  has_many :cell_chord_transactions, through: :cells
  has_many :cell_flag_transactions, through: :cells
  has_many :cell_unflag_transactions, through: :cells

  has_many :users,
           -> { select("DISTINCT ON(users.id) users.*").order("users.id") },
           through: :cell_transactions
  has_many :observers,
           ->(game) {
             select(
               "DISTINCT ON(users.id) users.*, game_transactions.created_at").
               where.not(id: User.for_game(game).select(:id))
           },
           through: :game_join_transactions,
           source: :user

  has_statuses([
    "Standing By",
    "Sweep in Progress",
    "Alliance Wins",
    "Mines Win",
  ])

  scope :for_type, ->(type) { where(type:) }
  scope :for_beginner_type, -> { where(type: BEGINNER_TYPE) }
  scope :for_intermediate_type, -> { where(type: INTERMEDIATE_TYPE) }
  scope :for_expert_type, -> { where(type: EXPERT_TYPE) }
  scope :for_game_on_statuses, -> {
    for_status([status_standing_by, status_sweep_in_progress])
  }
  scope :for_game_over_statuses, -> {
    for_status([status_alliance_wins, status_mines_win])
  }
  scope :for_ended_at, ->(time_range) { where(ended_at: time_range) }

  scope :by_most_recently_ended, -> { order(ended_at: :desc) }
  scope :by_score_asc, -> { where.not(score: nil).order(score: :asc) }
  scope :by_bbbvps_desc, -> { where.not(bbbvps: nil).order(bbbvps: :desc) }
  scope :by_efficiency_desc, -> {
    where.not(efficiency: nil).order(efficiency: :desc)
  }

  validates :type, presence: true

  def self.find_or_create_current(...)
    current || create_for(...)
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition where > 1 Game is being created at the same time.
    retry
  end

  def self.current = for_game_on_statuses.take
  def self.current! = for_game_on_statuses.take!

  def self.create_for(user:, **)
    build_for(**).tap { |new_game|
      transaction do
        new_game.save!
        GameCreateTransaction.create_between(user:, game: new_game)
        new_game.board.generate_cells
      end
    }
  end

  # @attr settings [Board::Settings]
  def self.build_for(settings:)
    new(type: settings.type).tap { |new_game|
      new_game.build_board(settings:)
    }
  end

  def self.display_id_width
    @display_id_width ||= [largest_id.digits.size, 4].max
  end

  def display_id = "##{id.to_s.rjust(self.class.display_id_width, "0")}"

  def version
    @version ||= Time.now.to_f
  end

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
      set_stats
    }
  end

  def end_in_defeat(user:)
    end_game(user:) {
      set_status_mines_win!
    }
  end

  def update_started_at(time:)
    touch(:started_at, time:)
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

  def just_ended? = !!just_ended
  def ended_in_victory? = status_alliance_wins?
  def ended_in_defeat? = status_mines_win?

  def engagement_time_range
    started_at..(ended_at if over?)
  end

  def duration
    ended_at - started_at if over?
  end

  def board_settings = board&.settings

  private

  attr_accessor :just_ended

  def end_game(user:)
    return self if over?

    transaction do
      GameEndTransaction.create_between(user:, game: self)
      yield
    end

    self
  end

  def set_stats
    CalcStats.(self)
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

    def inspect_name = display_id
  end

  # Game::CalcStats determines and updates the given {Game} object with relevant
  # statistical values (on {Game} end).
  class CalcStats
    include CallMethodBehaviors

    def initialize(game)
      @game = game
    end

    def call
      game.update(
        score:,
        bbbv:,
        bbbvps:,
        efficiency:)
    end

    private

    attr_reader :game

    def score
      [duration, MAX_SCORE].min
    end

    def duration = game.duration

    def bbbv
      @bbbv ||= Board::Calc3BV.(grid)
    end

    def grid = game.board.grid

    def bbbvps
      bbbv / score.to_f
    end

    def efficiency
      bbbv / clicks_count.to_f
    end

    def clicks_count = game.cell_transactions.size
  end

  # Game::Console acts like a {Game} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def render
      puts inspect # rubocop:disable Rails/Output
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
      current_game = Game.current

      if current_game && current_game != __model__
        raise(Error, "Can't reset a past Game while a current Game exists.")
      end

      current_game
    end
  end
end
