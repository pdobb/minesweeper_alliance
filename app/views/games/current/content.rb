# frozen_string_literal: true

# Games::Current::Content represents the updateable {Game} content for the
# current {Game}.
class Games::Current::Content
  def self.turbo_frame_name = :current_game_content

  def initialize(current_game:)
    @current_game = current_game
  end

  def turbo_frame_name = self.class.turbo_frame_name

  def status
    Games::Current::Status.new(current_game:)
  end

  def board
    Games::Current::Board.new(board: current_game.board)
  end

  private

  attr_reader :current_game
end
