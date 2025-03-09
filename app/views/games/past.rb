# frozen_string_literal: true

# Games::Past is a View Model meant for servicing general
# "Past Game"-based needs for other, more specific View Models.
class Games::Past
  include CallMethodBehaviors

  def initialize(game:)
    @game = game
  end

  def statusmoji
    if ended_in_victory?
      Emoji.victory
    elsif ended_in_defeat?
      Emoji.mine
    end
  end

  def outcome
    if ended_in_victory?
      "Alliance wins!"
    elsif ended_in_defeat?
      "Mines win"
    end
  end

  private

  attr_reader :game

  def ended_in_defeat? = game.ended_in_defeat?
  def ended_in_victory? = game.ended_in_victory?
end
