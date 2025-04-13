# frozen_string_literal: true

# :reek:MissingSafeMethod

# Game::EndInDefeat handles the "End In Defeat" event for the given {Game}.
class Game::EndInDefeat
  def self.call(...) = new(...).call

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def call
    return game if not_endable?

    do_call

    game
  end

  private

  attr_reader :game,
              :user

  def transaction(...) = game.transaction(...)
  def over? = Game::Status.over?(game)
  def set_status_mines_win! = game.set_status_mines_win!

  def not_endable? = over?

  def do_call
    transaction do
      record_event
      update_game_status
    end
  end

  def record_event
    GameEndTransaction.create_between(user:, game:)
  end

  def update_game_status
    set_status_mines_win!
  end
end
