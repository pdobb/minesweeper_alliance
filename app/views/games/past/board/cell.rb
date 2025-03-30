# frozen_string_literal: true

# Games::Past::Board::Cell is a View Model for displaying Inactive
# {Cell}s. i.e. for a {Game} that's no longer In-Progress.
class Games::Past::Board::Cell
  # rubocop:disable Layout/MultilineArrayLineBreaks
  BG_ERROR_COLOR = %w[
    bg-red-600 dark:bg-red-800
    shadow-inner shadow-gray-600 dark:shadow-neutral-800
  ].freeze
  # rubocop:enable Layout/MultilineArrayLineBreaks
  DIMMED_TEXT_COLOR = %w[text-dim-lg].freeze

  include Games::Board::CellBehaviors

  def initialize(cell, game:)
    @cell = cell
    @game = game
  end

  def css
    if revealed?
      mine? ? BG_ERROR_COLOR : DIMMED_TEXT_COLOR
    elsif incorrectly_flagged?
      BG_ERROR_COLOR
    elsif !flagged?
      BG_UNREVEALED_CELL_COLOR
    end
  end

  # :reek:DuplicateMethodCall

  def to_s
    return super unless mine?

    if revealed?
      Emoji.mine
    elsif flagged?
      Emoji.flag
    else
      game_ended_in_victory? ? Emoji.flag : Emoji.mine
    end
  end

  private

  attr_reader :cell,
              :game

  def game_ended_in_victory? = game.ended_in_victory?
  def incorrectly_flagged? = Cell::State.incorrectly_flagged?(cell)
end
