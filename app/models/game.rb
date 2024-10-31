# frozen_string_literal: true

# Game represents a game of Minesweeper Alliance. It handles creation of new
# Games and keeps track of the {#status} of each Game in the database, win or
# lose.
#
# @attr status [String] The current Game status / life-cycle state.
# @attr type [String] The preset or Game type used to generate this Game's
#   {Board} / {Grid} of {Cell}s.
#   Note: This attribute/column is *not* used for STI.
# @attr started_at [DateTime] When this Game started. i.e. transitioned from
#   {#status} "Standing By" to "Sweep in Progress".
# @attr ended_at [DateTime] When this Game ended. i.e. transitioned from
#   {#status} "Sweep in Progress" to either "Alliance Wins" or "Mines Win".
# @attr score [Integer] The play-time in seconds of a victorious Game. Maxes out
#   at {Game::CalcStats::MAX_SCORE} (999).
# @attr bbbv [Integer] The 3BV value for the associated, solved {Board}.
# @attr bbbvps [Float] The 3BV/s rating of a solved {Board}.
# @attr efficiency [Float] The ratio of actual clicks vs necessary clicks (3BV)
#   used to solve the associated {Board}.
class Game < ApplicationRecord
  self.inheritance_column = nil
  self.implicit_order_column = "created_at"

  ALL_TYPES = [
    BEGINNER_TYPE = "Beginner",
    INTERMEDIATE_TYPE = "Intermediate",
    EXPERT_TYPE = "Expert",
    CUSTOM_TYPE = "Custom",
    PATTERN_TYPE = "Pattern",
  ].freeze

  DEFAULT_JUST_ENDED_DURATION = 0.5.seconds

  include ConsoleBehaviors
  include Statusable::HasStatuses

  has_one :board, dependent: :delete
  validates_associated :board, on: :create

  has_many :cells, through: :board

  has_many :cell_transactions, through: :cells
  has_many :cell_reveal_transactions, through: :cells
  has_many :cell_chord_transactions, through: :cells
  has_many :cell_flag_transactions, through: :cells
  has_many :cell_unflag_transactions, through: :cells

  has_many :users,
           -> { select("DISTINCT ON(users.id) users.*").order("users.id") },
           through: :cell_transactions

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

  def self.find_or_create_current(...)
    current || create_for(...)
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition where > 1 Game is being created at the same time.
    retry
  end

  def self.current(within: DEFAULT_JUST_ENDED_DURATION)
    for_game_on_statuses.or(
      for_game_over_statuses.for_ended_at(within.ago..)).
      last
  end

  def self.create_for(...)
    build_for(...).tap { |new_game|
      transaction do
        new_game.save!
        new_game.board.on_create
      end
    }
  end

  # @attr settings [Board::Settings]
  def self.build_for(settings:)
    new(type: settings.type).tap { |new_game|
      new_game.build_board(settings:)
    }
  end

  # :reek:TooManyStatements

  def start(seed_cell:)
    return self unless status_standing_by?

    transaction do
      touch(:started_at)
      board.on_game_start(seed_cell:)
      set_status_sweep_in_progress!
    end

    self
  end

  def end_in_victory
    end_game {
      set_stats
      set_status_alliance_wins!
    }
  end

  def end_in_defeat
    end_game { set_status_mines_win! }
  end

  def on?
    status?([status_standing_by, status_sweep_in_progress])
  end

  def over?
    !on?
  end

  def just_ended?(within: DEFAULT_JUST_ENDED_DURATION)
    (within.ago..).cover?(ended_at)
  end

  def recently_ended? = just_ended?(within: 1.minute)

  def ended_in_victory? = status_alliance_wins?
  def ended_in_defeat? = status_mines_win?

  def engagement_time_range
    # TODO: Use Start/Stop Transactions for this instead, if/when available.
    started_at..(ended_at if over?)
  end

  def duration = ended_at - started_at

  def board_settings = board&.settings

  private

  def end_game
    return self if over?

    transaction do
      touch(:ended_at)
      yield
    end

    self
  end

  def set_stats
    CalcStats.(self)
  end

  # Game::CalcStats determines and updates the given Game object with relevant
  # statistical values (on Game end).
  class CalcStats
    MAX_SCORE = 999

    include CallMethodBehaviors

    def initialize(game)
      @game = game
    end

    def call
      game.update(
        score: score,
        bbbv: bbbv,
        bbbvps: bbbvps,
        efficiency: efficiency)
    end

    private

    attr_reader :game

    def score
      [duration, MAX_SCORE].min
    end

    def duration = game.duration

    def bbbv
      @bbbv ||= Calc3BV.(grid)
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
        update(started_at: Time.current)
        board.reset
      }
    end

    # Like {#reset} but also resets status to "Standing By" and reset mines on
    # the {Board}.
    def reset!
      do_reset {
        set_status_standing_by!
        update(started_at: nil)
        board.reset!
      }
    end

    private

    def inspect_flags(scope:)
      scope.join_flags([
        type,
        status,
      ])
    end

    def inspect_info(scope:)
      scope.join_info([
        "Score: #{score}",
        "3BV: #{bbbv}",
        "Efficiency: #{efficiency}",
      ])
    end

    def inspect_name = game_number

    def game_number = "##{id.to_s.rjust(4, "0")}"

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

        CellTransaction.for_id(cell_transaction_ids).delete_all

        yield
      end

      broadcast_refresh_to(:current_game)

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
