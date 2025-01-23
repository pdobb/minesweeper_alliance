# frozen_string_literal: true

# Games::Current::Status represents the current status ("Standing By" vs
# "Sweep In Progress") for the current {Game}.
class Games::Current::Status
  def self.game_status_turbo_update_target = "currentGameStatus"
  def self.fleet_size_turbo_update_target = "fleetSize"

  def initialize(game:)
    @game = game
  end

  def game_status_with_emoji
    "#{game_status} #{game_status_emoji}"
  end

  def game_status_turbo_update_target
    self.class.game_status_turbo_update_target
  end

  def fleet_size_turbo_update_target = self.class.fleet_size_turbo_update_target

  def fleet_size = FleetTracker.count

  private

  attr_reader :game

  def game_status = game.status

  def game_status_emoji
    game_standing_by? ? Emoji.anchor : Emoji.ship
  end

  def game_standing_by? = game.status_standing_by?
end
