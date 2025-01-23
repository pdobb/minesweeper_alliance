# frozen_string_literal: true

# Games::Current::Content represents the updateable {Game} content for the
# current {Game}.
class Games::Current::Content
  def self.turbo_frame_name = :current_game_content

  def initialize(game:)
    @game = game
  end

  def turbo_frame_name = self.class.turbo_frame_name

  def board
    Games::Current::Board.new(board: game.board)
  end

  private

  attr_reader :game
end
