# frozen_string_literal: true

# Metrics::Games::Content represents {Game} content for past {Game}s in the
# context of the Metrics Show page.
class Metrics::Games::Content
  def initialize(game:)
    @game = game
  end

  def title
    Metrics::Games::Title.new(game:)
  end

  def board
    Games::Past::Board.new(board: game.board)
  end

  private

  attr_reader :game
end
