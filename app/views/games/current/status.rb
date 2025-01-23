# frozen_string_literal: true

# Games::Current::Status represents the current status (Standing By vs Sweep In
# Progress) for the current {Game}.
class Games::Current::Status
  def self.broadcast_fleet_size_update
    WarRoomChannel.broadcast_update(
      target: :fleet_size,
      html: FleetTracker.count)
  end

  def initialize(game:)
    @game = game
  end

  def game_status_with_emoji
    "#{game_status} #{game_status_emoji}"
  end

  def fleet_size = FleetTracker.count

  private

  attr_reader :game

  def game_status = game.status

  def game_status_emoji
    game_standing_by? ? Emoji.anchor : Emoji.ship
  end

  def game_standing_by? = game.status_standing_by?
end
