# frozen_string_literal: true

class Game < ApplicationRecord
  include Statusable::HasStatuses

  has_one :board

  has_statuses([
    "Initializing",
    "In-Progress",
    "Alliance Wins",
    "Mines Win",
  ])

  def self.create_for(...)
    new_game = build_for(...).tap(&:save!)

    # FIXME: Move elsewhere.
    new_game.board.place_mines
    new_game.set_status_in_progress!
    new_game
  end

  def self.build_for(difficulty_level)
    new.tap { |new_game|
      Board.build_for(new_game, difficulty_level:)
    }
  end

  def end_in_victory
    set_status_alliance_wins!
  end

  def end_in_defeat
    set_status_mines_win!
  end

  private

  def inspect_identification
    identify
  end

  def inspect_flags
    status
  end
end
