# frozen_string_literal: true

# Game represents a game of Minesweeper Alliance. It handles creation of new
# Games and keeps track of the #status} of each Game in the database, win or
# lose.
class Game < ApplicationRecord
  self.implicit_order_column = "created_at"

  include ConsoleBehaviors
  include Statusable::HasStatuses

  has_one :board, dependent: :delete

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

  def self.current(within: 1.second)
    for_game_on_statuses.or(
      for_game_over_statuses.for_ended_at(within.ago..)).
      take
  end

  def self.create_for(...)
    build_for(...).tap { |new_game|
      new_game.save!

      new_game.broadcast_refresh_to(:current_game)
    }
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

    # :reek:TooManyStatements

    def reset(time: Time.current) # rubocop:disable Metrics/MethodLength
      current_game = Game.current
      if current_game && current_game != __to_model__
        raise(Error, "Can't reset a past Game while a current Game exists.")
      end

      transaction do
        update(
          started_at: time,
          ended_at: nil,
          updated_at: time)

        set_status_sweep_in_progress! if over?

        board.console.reset
      end

      broadcast_refresh_to(:current_game)

      self
    end

    private

    def inspect_flags = status
    def inspect_info = engagement_time_range
  end
end
