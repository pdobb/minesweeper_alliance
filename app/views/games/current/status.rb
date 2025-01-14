# frozen_string_literal: true

# Games::Current::Status represents the status (Standing By vs Sweep In
# Progress) for the current {Game}.
class Games::Current::Status
  def self.broadcast_fleet_size_update
    WarRoomChannel.broadcast_update(
      target: :fleet_size,
      html: FleetTracker.count)
  end

  def self.broadcast_status_update(current_game:)
    WarRoomChannel.broadcast_replace(
      target: :current_game_status,
      html: game_status(current_game:))
  end

  def self.game_status(current_game:) = Games::Current.new(current_game:).status

  def initialize(current_game:)
    @current_game = current_game
  end

  def game_status = self.class.game_status(current_game:)

  def roster
    Games::Current::Roster.new(current_game:)
  end

  def fleet_size = FleetTracker.count

  private

  attr_reader :current_game
end
