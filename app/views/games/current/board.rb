# frozen_string_literal: true

# Games::Current::Board represents the {Board} for the current {Game}.
class Games::Current::Board
  def initialize(board:)
    @board = board
  end

  def header
    Games::Current::Board::Header.new(board:)
  end

  def scroll_position_storage_key = Home::Show.game_board_storage_key

  def content
    Games::Current::Board::Content.new(board:)
  end

  def footer
    Games::Board::Footer.new(board:)
  end

  private

  attr_reader :board

  def game = board.game
  def game_on? = game.on?
end
