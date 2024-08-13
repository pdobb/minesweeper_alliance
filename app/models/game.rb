# frozen_string_literal: true

class Game < ApplicationRecord
  has_one :board

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
end
