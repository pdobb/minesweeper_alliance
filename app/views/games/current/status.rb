# frozen_string_literal: true

# Games::Current::Status represents the status (Standing By vs Sweep In
# Progress) for the current {Game}.
class Games::Current::Status
  def self.broadcast_fleet_size_update(stream_name:)
    WarRoomChannel.broadcast_update_to(
      stream_name,
      target: :fleet_size,
      html: FleetTracker.count)
  end

  def initialize(current_game:)
    @current_game = current_game
  end

  def game_status_css
    if game_ended_in_defeat?
      %w[text-red-700 dark:text-red-600]
    elsif game_ended_in_victory?
      %w[text-green-700 dark:text-green-600]
    end
  end

  def game_status = current_game.status

  def game_status_emoji
    game_standing_by? ? Emoji.anchor : Emoji.ship
  end

  def roster
    Games::Current::Roster.new(current_game:)
  end

  def fleet_size = FleetTracker.count

  private

  attr_reader :current_game

  def game_standing_by? = current_game.status_standing_by?
  def game_ended_in_defeat? = current_game.ended_in_defeat?
  def game_ended_in_victory? = current_game.ended_in_victory?
end
