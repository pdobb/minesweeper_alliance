# frozen_string_literal: true

# Game represents a game of Minesweeper Alliance. It handles creation of new
# Games and keeps track of the {#status} of each Game in the database, win or
# lose.
#
# @attr status [String] The current Game status / lifecycle state.
# @attr difficulty_level [String] The Difficulty Level name that was used to
#   generate this Game's {Board} / {Grid} of {Cell}s.
# @attr started_at [DateTime] When this Game started. i.e. transitioned from
#   {#status} "Standing By" to "Sweep in Progress".
# @attr ended_at [DateTime] When this Game ended. i.e. transitioned from
#   {#status} "Sweep in Progress" to either "Alliance Wins" or "Mines Win".
class Game < ApplicationRecord
  self.implicit_order_column = "created_at"

  DEFAULT_JUST_ENDED_DURATION = 1.second

  include ConsoleBehaviors
  include Statusable::HasStatuses

  has_one :board, dependent: :delete

  has_many :cell_transactions, through: :board
  has_many :cell_reveal_transactions, through: :board
  has_many :cell_flag_transactions, through: :board
  has_many :cell_unflag_transactions, through: :board

  has_statuses([
    "Standing By",
    "Sweep in Progress",
    "Alliance Wins",
    "Mines Win",
  ])

  scope :for_game_on_statuses, -> {
    for_status([status_standing_by, status_sweep_in_progress])
  }
  scope :for_game_over_statuses, -> {
    for_status([status_alliance_wins, status_mines_win])
  }
  scope :for_ended_at, ->(time_range) { where(ended_at: time_range) }
  scope :for_difficulty_level_test,
        -> { where(difficulty_level: DifficultyLevel::TEST) }

  scope :by_most_recently_ended, -> { order(ended_at: :desc) }

  def self.find_or_create_current(...)
    current || create_for(...)
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition where > 1 Game is being created at the same time.
    retry
  end

  def self.current(within: DEFAULT_JUST_ENDED_DURATION)
    for_game_on_statuses.or(
      for_game_over_statuses.for_ended_at(within.ago..)).
      take
  end

  def self.create_for(...)
    build_for(...).tap(&:save!)
  end

  # @attr difficulty_level [DifficultyLevel, String, #to_difficulty_level]
  def self.build_for(difficulty_level:)
    difficulty_level = Conversions.DifficultyLevel(difficulty_level)

    new(difficulty_level:).tap { |new_game|
      Board.build_for(game: new_game, difficulty_level:)
    }
  end

  def difficulty_level
    DifficultyLevel.new(super)
  end

  # :reek:TooManyStatements

  def start(seed_cell:)
    return self unless status_standing_by?

    transaction do
      touch(:started_at)
      board.place_mines(seed_cell:)
      set_status_sweep_in_progress!
    end

    self
  end

  def end_in_victory
    end_game { set_status_alliance_wins! }
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

  def ended_in_victory? = status_alliance_wins?
  def ended_in_defeat? = status_mines_win?

  def engagement_time_range
    # TODO: Use Start/Stop Transactions for this instead, if/when available.
    started_at..(ended_at if over?)
  end

  private

  def end_game
    return self if over?

    transaction do
      touch(:ended_at)
      yield
    end

    self
  end

  # Game::Console acts like a {Game} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def self.purge_difficulty_level_test
      result_count = for_difficulty_level_test.delete_all
      puts( # rubocop:disable Rails/Output
        " -> Purged #{result_count} #{DifficultyLevel::TEST.inspect} Games. "\
        "Restart the Rails server into DEBUG mode for changes to take effect.")
    end

    def render
      puts inspect # rubocop:disable Rails/Output
      board.render
    end

    # :reek:TooManyStatements
    def reset(time: Time.current)
      check_for_current_game

      transaction do
        update!(
          started_at: time,
          ended_at: nil,
          updated_at: time)

        set_status_sweep_in_progress! if over?

        board.reset
      end

      broadcast_refresh_to(:current_game)

      self
    end

    # Like {#reset} but also resets status to "Standing By" and reset mines on
    # the {Board}.
    #
    # :reek:TooManyStatements
    def reset!(time: Time.current)
      check_for_current_game

      transaction do
        update!(
          started_at: time,
          ended_at: nil,
          updated_at: time)

        set_status_standing_by!

        board.reset!
      end

      broadcast_refresh_to(:current_game)

      self
    end

    private

    def inspect_flags(scope:)
      scope.join_flags([
        difficulty_level,
        status,
      ])
    end

    def inspect_info = engagement_time_range

    def check_for_current_game
      current_game = Game.current

      # rubocop:disable Style/GuardClause
      if current_game && current_game != __model__
        raise(Error, "Can't reset a past Game while a current Game exists.")
      end
      # rubocop:enable Style/GuardClause
    end
  end
end
