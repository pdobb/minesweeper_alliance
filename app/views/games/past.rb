# frozen_string_literal: true

# Games::Past is a View Model meant for servicing general
# "Past Game"-based needs for other, more specific View Models.
class Games::Past
  include CallMethodBehaviors

  def initialize(game:)
    @game = game
  end

  def status_mojis
    if ended_in_defeat?
      Emoji.mine
    elsif ended_in_victory?
      "#{Emoji.ship}#{Emoji.victory}"
    end
  end

  private

  attr_reader :game

  def ended_in_defeat? = game.ended_in_defeat?
  def ended_in_victory? = game.ended_in_victory?
end
