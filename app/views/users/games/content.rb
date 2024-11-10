# frozen_string_literal: true

# Users::Games::Content represents {Game} content for past {Game}s in the
# context of a {User}.
class Users::Games::Content
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def title
    Users::Games::Title.new(game:, user:)
  end

  def board
    Games::Past::Board.new(board: game.board)
  end

  private

  attr_reader :game,
              :user
end
