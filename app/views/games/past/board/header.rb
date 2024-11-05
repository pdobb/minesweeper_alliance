# frozen_string_literal: true

# Games::Past::Board::Header represents the {Board} header for past {Game}s.
class Games::Past::Board::Header
  def initialize(board:)
    @board = board
  end

  def flags_count = board.flags_count
  def mines = board.mines

  def elapsed_time
    @elapsed_time ||= Games::Board::ElapsedTime.new(game_engagement_time_range)
  end

  private

  attr_reader :board

  def game = board.game

  def game_engagement_time_range = game.engagement_time_range
end
