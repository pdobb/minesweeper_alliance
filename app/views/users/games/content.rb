# frozen_string_literal: true

# Users::Games::Content represents {Game} content for past {Game}s in the
# context of a {User}.
class Users::Games::Content
  def initialize(game:)
    @game = game
  end

  def title
    Games::Title.new(game:)
  end

  def board
    Games::Past::Board.new(board: game.board)
  end

  private

  attr_reader :game
end
