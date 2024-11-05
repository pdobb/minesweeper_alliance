# frozen_string_literal: true

# Games::Past::Content represents the {Game} content for past {Game}s.
class Games::Past::Content
  def initialize(game:)
    @game = game
  end

  def title
    Games::Title.new(game:)
  end

  def status
    Games::Past::Status.new(game:)
  end

  def board
    Games::Past::Board.new(board: game.board)
  end

  private

  attr_reader :game
end
