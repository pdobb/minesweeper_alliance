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
  validates_associated :board, on: :create

  has_many :cells, through: :board

  has_many :cell_transactions, through: :cells
  has_many :cell_reveal_transactions, through: :cells
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

  scope :for_game_on_statuses, -> {
    for_status([status_standing_by, status_sweep_in_progress])
  }
  scope :for_game_over_statuses, -> {
    for_status([status_alliance_wins, status_mines_win])
  }
  scope :for_ended_at, ->(time_range) { where(ended_at: time_range) }

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
      last
  end

  def self.create_for(...)
    build_for(...).tap { |new_game|
      transaction do
        new_game.save!
        Board::Generate.(new_game.board)
      end
    }
  end

  # @attr settings [Board::Settings]
  def self.build_for(settings:)
    new(difficulty_level: settings.name).tap { |new_game|
      new_game.build_board(settings:)
    }
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

    def render
      puts inspect # rubocop:disable Rails/Output
      board.render
    end

    def reset
      do_reset {
        set_status_sweep_in_progress! if over?
        board.reset
      }
    end

    # Like {#reset} but also resets status to "Standing By" and reset mines on
    # the {Board}.
    def reset!
      do_reset {
        set_status_standing_by!
        board.reset!
      }
    end

    private

    def inspect_flags(scope:)
      scope.join_flags([
        difficulty_level,
        status,
      ])
    end

    def inspect_info = engagement_time_range

    # :reek:TooManyStatements
    def do_reset
      check_for_current_game

      transaction do
        update!(started_at: nil, ended_at: nil)

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
