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
# - If a mine is revealed, the {Game} ends in defeat.
# - If all safe Cells are revealed, the {Game} ends in victory for the alliance!
#
# @attr coordinates [Coordinates] ({}) Storage of the X/Y Grid location.
# @attr value [Integer] (nil) The revealed value; a number (0..8)
#   representing the number of mines around this Cell.
# @attr mine [Boolean] Whether or not this Cell contains a mine.
# @attr flagged [Boolean] Whether or not this Cell has been flagged.
# @attr highlighted [Boolean] Whether or not this Cell is currently being
#   highlighted. (This is highly temporary.)
# @attr revealed [Boolean] Whether or not this Cell has been revealed.
class Cell < ApplicationRecord
  self.implicit_order_column = "created_at"

  VALUES_RANGE = 0..8
  BLANK_VALUE = 0

  include ConsoleBehaviors

  belongs_to :board, inverse_of: :cells
  has_one :game, through: :board

  has_many :cell_transactions, dependent: :delete_all
  has_one :cell_reveal_transaction
  has_many :cell_flag_transactions
  has_many :cell_unflag_transactions

  attribute :coordinates, CoordinatesType.new
  def x = coordinates.x
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
  scope :for_board, ->(board) { where(board:) }
  scope :for_game, ->(game) { joins(:board).merge(Board.for_game(game)) }

  validates :coordinates,
            presence: true,
            uniqueness: { scope: :board_id }
  validates :value,
            numericality: { integer: true, in: VALUES_RANGE, allow_blank: true }

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
    return self if unrevealed?

    neighbors.is_not_flagged.is_not_revealed.is_not_highlighted.update_all(
      highlighted: true)

    self
  end

  # "Dehighligting" removes the highlight added by {#highlight_neighbors}
  # from the neighboring, highlighted Cells.
  def dehighlight_neighbors
    return self if unrevealed?

    neighbors.is_highlighted.update_all(highlighted: false)

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
  def correctly_flagged? = flagged? && mine?
  def incorrectly_flagged? = flagged? && !mine?
  def blank? = value == BLANK_VALUE

  private

  def determine_revealed_value
    neighboring_mines_count
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

    def coordinates = super.console
    def neighbors = super.map(&:console)

    def render(cells_count: nil)
      "#{current_state}#{coordinates.console.render(cells_count:)}"
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
        " #{value}"
      elsif flagged?
        Icon.flag
      else
        Icon.cell
      end
    end
  end
end
