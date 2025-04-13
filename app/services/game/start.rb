# frozen_string_literal: true

# :reek:MissingSafeMethod

# Game::Start handles the "Game Start" event for the given {Game}.
class Game::Start
  def self.call(...) = new(...).call

  def initialize(game:, user:, seed_cell:)
    @game = game
    @user = user
    @seed_cell = seed_cell
  end

  def call
    return game unless startable?

    do_call

    game
  end

  private

  attr_reader :game,
              :user,
              :seed_cell

  def status_standing_by? = game.status_standing_by?
  def transaction(...) = game.transaction(...)
  def board = game.board
  def set_status_sweep_in_progress! = game.set_status_sweep_in_progress!

  def startable? = status_standing_by?

  def do_call
    transaction do
      record_event
      place_mines
      update_game_status
    end
  end

  def record_event
    GameStartTransaction.create_between(user:, game:)
  end

  def place_mines
    Board::DetermineMinesPlacement.(board:, seed_cell:)
  end

  def update_game_status
    set_status_sweep_in_progress!
  end
end
