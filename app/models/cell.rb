# frozen_string_literal: true

# Cell represents a clickable position on the {Board}. Cells:
# - may secretly contain a mine
# - may be blank (indicating that neither it nor any of its neighbors are
#   mines)
# - or will otherwise indicate how many of its neighboring Cells do contain a
#   mine once revealed.
#
# Which of these values a Cell is, is discovered when the Cell is revealed (when
# a player clicks on the Cell).
# - If a mine is revealed, the {Game} ends in victory for the mines!
# - If all safe Cells are revealed, the {Game} ends in victory for the alliance!
class Cell < ApplicationRecord
  CELL_ICON = "◻️"
  REVEALED_CELL_ICON = "☑️"
  MINE_ICON = "💣"
  FLAG_ICON = "🚩"

  BLANK_VALUE = "0"

  belongs_to :board, touch: true

  attribute :coordinates, CoordinatesType.new
  delegate :x,
           :y,
           to: :coordinates

  scope :is_a_mine, -> { where(mine: true) }
  scope :is_not_a_mine, -> { where(mine: false) }
  scope :is_flagged, -> { where(flagged: true) }
  scope :is_revealed, -> { where(revealed: true) }
  scope :is_not_revealed, -> { where(revealed: false) }

  scope :for_coordinates, ->(coordinates) { where(coordinates:) }

  scope :by_least_recent, -> { order(:id) } # rubocop:disable Rails/OrderById
  scope :by_random, -> { order("RANDOM()") }

  def display_name
    value.inspect
  end

  def reveal
    return self if revealed?

    update(
      revealed: true,
      value: determine_value)

    if mine?
      board.end_game_in_defeat
      return self
    end

    neighbors.each(&:reveal) if blank?

    board.check_for_victory

    self
  end

  def blank?
    value == BLANK_VALUE
  end

  def neighboring_mines_count = neighbors.is_a_mine.count

  def neighbors
    return Cell.none unless board

    board.cells.for_coordinates(neighboring_coordinates)
  end

  def neighboring_coordinates
    return [] unless board

    board.clamp_coordinates(coordinates.neighbors)
  end

  def render
    "#{current_state} #{coordinates.render}"
  end

  private

  def inspect_identification
    identify
  end

  def inspect_flags(scope:)
    scope.join_flags([
      current_state,
      (MINE_ICON if mine?),
    ])
  end

  def inspect_info
    coordinates.inspect
  end

  def determine_value
    mine? ? MINE_ICON : neighboring_mines_count
  end

  def current_state
    if revealed?
      "#{value} "
    elsif flagged?
      FLAG_ICON
    else
      CELL_ICON
    end
  end
end
