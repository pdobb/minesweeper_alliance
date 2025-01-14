# frozen_string_literal: true

# Games::Current is a View Model meant for servicing general
# "Current Game"-based needs for other, more specific View Models.
class Games::Current
  include CallMethodBehaviors

  def initialize(current_game:)
    @current_game = current_game
  end

  def status
    "#{game_status} #{game_status_emoji}"
  end

  private

  attr_reader :current_game

  def game_status = current_game.status

  def game_status_emoji
    game_standing_by? ? Emoji.anchor : Emoji.ship
  end

  def game_standing_by? = current_game.status_standing_by?
end
