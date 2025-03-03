# frozen_string_literal: true

# Games::JustEnded::Content represents the {Game} content for {Game}s that have
# just ended.
class Games::JustEnded::Content
  def initialize(game:)
    @game = game
  end

  def title
    Games::JustEnded::Title.new(game:)
  end

  def status
    Games::Past::Status.new(game:)
  end

  def board
    Games::JustEnded::Board.new(board: game.board)
  end

  def actions
    Games::JustEnded::Actions.new(game:)
  end

  private

  attr_reader :game
end
