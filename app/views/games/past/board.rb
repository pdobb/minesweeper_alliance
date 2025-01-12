# frozen_string_literal: true

# Games::Past::Board represents the {Board} for past {Game}s.
class Games::Past::Board
  def initialize(board:)
    @board = board
  end

  def header
    Games::Past::Board::Header.new(board:)
  end

  def content
    Games::Past::Board::Content.new(board:)
  end

  def footer
    Games::Past::Board::Footer.new(board:)
  end

  private

  attr_reader :board
end
