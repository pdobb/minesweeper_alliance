# frozen_string_literal: true

# Games::Current::Board::Header represents the {Board} header for the current
# {Game}.
class Games::Current::Board::Header
  def self.placed_flags_count_turbo_target = "placedFlagsCount"

  def initialize(board:)
    @board = board
  end

  def placed_flags_count_turbo_target
    self.class.placed_flags_count_turbo_target
  end

  def flags_count = board.flags_count
  def mines = board.mines

  def elapsed_time
    @elapsed_time ||= Games::Board::ElapsedTime.new(game:)
  end

  private

  attr_reader :board

  def game = board.game
end
