# frozen_string_literal: true

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
  scope :is_flagged, -> { where(flagged: true) }
  scope :is_revealed, -> { where(revealed: true) }
  scope :is_not_revealed, -> { where(revealed: false) }

  scope :for_coordinates, ->(coordinates) { where(coordinates:) }

  scope :by_coordinates_asc, -> {
    order(Arel.sql("coordinates->>'y'").asc).
      order(Arel.sql("coordinates->>'x'").asc)
  }
  scope :by_random, -> { order("RANDOM()") }

  def display_name
    value.inspect
  end

  def reveal
    return self if revealed?

    # end_game(:fail) if mine?

    update(
      revealed: true,
      value: determine_value)

    # recurse if value is " " (i.e. no neighboring mines)

    # end_game(:win) if all_non_mine_cells_have_been_revealed?

    self
  end

  def neighboring_mines_count = neighbors.is_a_mine.count

  def neighbors
    return Cell.none unless board

    board.cells.for_coordinates(neighboring_coordinates).by_coordinates_asc
  end

  def neighboring_coordinates_grid
    Grid.new(neighboring_coordinates)
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
      (MINE_ICON if mine?)
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
      REVEALED_CELL_ICON
    elsif flagged?
      FLAG_ICON
    else
      CELL_ICON
    end
  end
end
