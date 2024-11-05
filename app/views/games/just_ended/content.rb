# frozen_string_literal: true

# Games::JustEnded::Content represents the {Game} content for {Game}s that have
# just ended.
class Games::JustEnded::Content
  def initialize(current_game:)
    @current_game = current_game
  end

  def title
    Games::Title.new(game: current_game)
  end

  def status
    Games::Past::Status.new(game: current_game)
  end

  def board
    Games::Past::Board.new(board: current_game.board)
  end

  def actions
    Games::JustEnded::Actions.new(current_game:)
  end

  private

  attr_reader :current_game
end
