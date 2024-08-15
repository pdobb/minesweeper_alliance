# frozen_string_literal: true

class Game < ApplicationRecord
  include Statusable::HasStatuses

  has_one :board

  has_statuses(%w[
    Initializing
    In-Progress
    Completed
  ])

  def self.create_for(...)
    build_for(...).tap(&:save!)
  end

  def self.build_for(difficulty_level)
    new_board = Board.build_for(new, difficulty_level:)
    new_board.game
  end

  private

  def inspect_identification
    identify
  end

  def inspect_flags
    status
  end
end
