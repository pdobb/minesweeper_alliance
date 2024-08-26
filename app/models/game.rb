# frozen_string_literal: true

# Game represents a game of Minesweeper Alliance. It handles creation of new
# Games and keeps track of the #status} of each Game in the database, win or
# lose.
class Game < ApplicationRecord
  include Statusable::HasStatuses

  has_one :board, dependent: :delete

  has_statuses([
    "In-Progress",
    "Alliance Wins",
    "Mines Win",
  ])

  def self.find_or_create_current(...)
    current || create_for(...)
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition where > 1 Game is being created at the same time.
    retry
  end

  def self.current
    for_status_in_progress.take
  end

  def self.create_for(...)
    new_game = build_for(...).tap(&:save!)

    # FIXME: Move elsewhere.
    new_game.board.place_mines
    new_game
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

  def end_in_victory
    set_status_alliance_wins!
  end

  def ended_in_victory?
    status_alliance_wins?
  end

  def end_in_defeat
    set_status_mines_win!
  end

  def over?
    not_status_in_progress?
  end

  def activity_interval
    # TODO: Use Start/Stop Transactions for this instead, if/when available.
    created_at..(updated_at unless status_in_progress?)
  end

  private

  def inspect_identification
    identify
  end

  def inspect_flags
    status
  end
end
