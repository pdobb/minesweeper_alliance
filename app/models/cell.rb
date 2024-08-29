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
# - If a mine is revealed, the {Game} ends in defeat (a.k.a. victory for the
#   mines).
# - If all safe Cells are revealed, the {Game} ends in victory for the alliance!
class Cell < ApplicationRecord
  BLANK_VALUE = "0"

  include ConsoleBehaviors

  belongs_to :board, touch: true

  attribute :coordinates, CoordinatesType.new

  # :reek:UncommunicativeMethodName
  def x = coordinates.x
  # :reek:UncommunicativeMethodName
  def y = coordinates.y

  scope :is_mine, -> { where(mine: true) }
  scope :is_not_mine, -> { where(mine: false) }
  scope :is_flagged, -> { where(flagged: true) }
  scope :is_not_flagged, -> { where(flagged: false) }
  scope :is_highlighted, -> { where(highlighted: true) }
  scope :is_not_highlighted, -> { where(highlighted: false) }
  scope :is_revealed, -> { where(revealed: true) }
  scope :is_not_revealed, -> { where(revealed: false) }

  scope :for_coordinates, ->(coordinates) { where(coordinates:) }

  scope :by_random, -> { order("RANDOM()") }

  def value
    super || (Icon.flag if flagged?)
  end

  def toggle_flag
    toggle!(:flagged)

    self
  end

  def reveal
    return self if revealed?

    update(
      revealed: true,
      highlighted: false,
      flagged: false,
      value: determine_revealed_value)

    self
  end

  # "Highlighting" marks the neighboring, non-flagged, and non-revealed Cells
  # for highlight in the view. This makes it easy to visualize the surrounding
  # Cells of a given, previously-revealed Cell.
  def highlight_neighbors
    rows_updated_count =
      neighbors.is_not_flagged.is_not_revealed.is_not_highlighted.update_all(
        highlighted: true)
    board.touch if rows_updated_count.positive?

    self
  end

  # "Dehighligting" removes the highlight added by {#highlight_neighbors}
  # from the neighboring, highlighted Cells.
  def dehighlight_neighbors
    return self if unrevealed?

    rows_updated_count = neighbors.is_highlighted.update_all(highlighted: false)
    board.touch if rows_updated_count.positive?

    self
  end

  def neighboring_flags_count_matches_value?
    neighboring_flags_count == value.to_i
  end

  def neighbors
    return Cell.none unless board

    board.cells.for_coordinates(neighboring_coordinates)
  end

  def unrevealed? = !revealed?
  def blank? = value == BLANK_VALUE
  def correctly_flagged? = flagged? && mine?
  def incorrectly_flagged? = flagged? && !mine?

  private

  def determine_revealed_value
    mine? ? Icon.mine : neighboring_mines_count
  end

  def neighboring_mines_count = neighbors.is_mine.size
  def neighboring_flags_count = neighbors.is_flagged.size

  def neighboring_coordinates
    return [] unless board

    board.clamp_coordinates(coordinates.neighbors)
  end

  # Cell::Console acts like a {Cell} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def render(cells_count: nil)
      "#{current_state} #{coordinates.console.render(cells_count:)}"
    end

    private

    def inspect_flags(scope:)
      scope.join_flags([
        (revealed? ? Icon.revealed_cell : Icon.cell),
        (Icon.flag if flagged?),
        (Icon.mine if mine?),
        (Icon.eyes if highlighted?),
      ])
    end

    def inspect_issues
      "INCORRECTLY_FLAGGED" if incorrectly_flagged?
    end

    def inspect_info = coordinates.console
    def inspect_name = value.inspect

    def current_state
      if revealed?
        "#{value} "
      elsif flagged?
        Icon.flag
      else
        Icon.cell
      end
    end
  end
end
