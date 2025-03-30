# frozen_string_literal: true

# Games::Board::CellBehaviors is a View Model mix-in for displaying {Cell}s for
# current/just-ended/past {Game}s.
module Games::Board::CellBehaviors
  extend ActiveSupport::Concern

  BG_UNREVEALED_CELL_COLOR = "bg-slate-400 dark:bg-neutral-700"

  include WrapMethodBehaviors

  def revealed? = cell.revealed?
  def flagged? = cell.flagged?

  def css
    raise(NotImplementedError)
  end

  def to_s
    if blank?
      ""
    elsif value
      value.to_s
    elsif flagged?
      Emoji.flag
    else # rubocop:disable Lint/DuplicateBranch
      ""
    end
  end

  private

  def value = cell.value
  def mine? = cell.mine?
  def blank? = Cell::State.blank?(cell)
end
