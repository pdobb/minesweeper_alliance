# frozen_string_literal: true

# Games::Current::Container represents the entire view context surrounding the
# current {Game}, as a partial for reuse.
class Games::Current::Container
  def self.broadcast_players_count_update(stream_name:, count:)
    count = [count, 1].max
    WarRoomChannel.broadcast_update_to(
      stream_name, target: :fleet_count, html: count)
  end

  def self.turbo_frame_name = :current_game_container

  def initialize(current_game:)
    @current_game = current_game
  end

  def partial_path
    "games/current/container"
  end

  def turbo_frame_name = self.class.turbo_frame_name

  def version = current_game.version

  def nav
    Games::Current::Nav.new
  end

  def content
    Games::Current::Content.new(current_game:)
  end

  def footer(context)
    Games::Current::Footer.new(context)
  end

  private

  attr_reader :current_game
end
