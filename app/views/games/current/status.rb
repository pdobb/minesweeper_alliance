# frozen_string_literal: true

# Games::Current::Status represents the current status ("Standing By" vs
# "Sweep In Progress") for the current {Game}.
class Games::Current::Status
  def self.game_status_turbo_target = "currentGameStatus"
  def self.fleet_size_turbo_target = "fleetSize"

  def initialize(game:)
    @game = game
  end

  def to_s
    "#{game_status} #{statusmoji}"
  end

  def game_status_turbo_target
    self.class.game_status_turbo_target
  end

  def fleet_size_turbo_target = self.class.fleet_size_turbo_target

  def fleet_size = FleetTracker.size

  private

  attr_reader :game

  def game_status = game.status

  def statusmoji
    standing_by? ? Emoji.anchor : Emoji.ship
  end

  def standing_by? = game.status_standing_by?
end
