# frozen_string_literal: true

# Cell::State provides services related to the various {Cell} states.
module Cell::State
  BLANK_VALUE = 0

  def self.unrevealed?(cell) = !cell.revealed?
  def self.revealable?(cell) = !(cell.revealed? || cell.flagged?)
  def self.safely_revealable?(cell) = !(cell.mine? || cell.revealed?)
  def self.incorrectly_flagged?(cell) = cell.flagged? && !cell.mine?
  def self.blank?(cell) = cell.value == BLANK_VALUE

  def self.highlightable?(cell)
    !(cell.revealed? || cell.flagged? || cell.highlighted?)
  end

  def self.dehighlightable?(cell) = cell.highlighted?
end
