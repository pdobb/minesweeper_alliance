# frozen_string_literal: true

# Icon is a module (as in a Class that is never instantiated) for easily
# referencing the various icons we use throughout the app.
module Icon
  def self.cell
    "◻️"
  end

  def self.revealed_cell
    "☑️"
  end

  def self.flag
    "🚩"
  end

  def self.mine
    "💣"
  end

  def self.eyes
    "👀"
  end

  def self.ship
    "⛴️"
  end

  def self.anchor
    "⚓️"
  end

  def self.victory
    "🎉"
  end

  def self.clover
    "🍀"
  end

  def self.heart
    "❤️"
  end

  def self.celebratory_victory
    "#{ship}#{anchor}#{victory}"
  end

  def self.humiliating_defeat
    mine
  end
end
