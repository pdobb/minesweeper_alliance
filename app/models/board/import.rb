# frozen_string_literal: true

require "csv"

# Board::Import is a Service Object for importing {Board} patterns as mines.
class Board::Import
  # Board::Import::Error represents any StandardError related to Board::Import
  # processing.
  Error = Class.new(StandardError)

  include CallMethodBehaviors

  attr_reader :board,
              :path

  def initialize(board:, filename:)
    @board = board
    @path = Rails.root.join("tmp/patterns/#{filename}.csv")
  end

  def on_call
    check_game_state
    place_mines
  end

  private

  def check_game_state
    raise(Error, "can't import to an in-progress Game") if game_in_progress?
  end

  def game_in_progress? = game.status_sweep_in_progress?
  def game = board.game

  def place_mines
    Board::PlaceMines.(board:, coordinates_array:)
  end

  # :reek:FeatureEnvy
  def coordinates_array
    CSV.foreach(path, headers: true, converters: :integer).map { |row|
      Coordinates[row["x"], row["y"]]
    }
  end
end
