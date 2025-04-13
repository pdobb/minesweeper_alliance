# frozen_string_literal: true

# :reek:MissingSafeMethod

# Game::EndInVictory handles the "End In Victory" event for the given {Game}.
class Game::EndInVictory
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
  def over? = game.over?
  def set_status_alliance_wins! = game.set_status_alliance_wins!

  def not_endable? = over?

  def do_call
    transaction do
      record_event
      update_game_status
      update_stats
    end
  end

  def record_event
    GameEndTransaction.create_between(user:, game:)
  end

  def update_game_status
    set_status_alliance_wins!
  end

  def update_stats
    Game::Stats::Calculate.(game)
  end
end
