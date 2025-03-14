# frozen_string_literal: true

# :reek:TooManyMethods
# :reek:RepeatedConditional
# :reek:InstanceVariableAssumption

# Cell represents a clickable position on the {Board}. Cells:
# - may secretly contain a mine
# - may be blank (indicating that neither it nor any of its neighbors are
#   mines)
# - or will otherwise indicate how many of its neighboring Cells do contain a
#   mine once revealed.
#
# Which of these values a Cell is is discovered when the Cell is revealed (when
# a player clicks on the Cell).
# - If a mine is revealed, the {Game} ends in defeat.
# - If all safe Cells are revealed, the {Game} ends in victory for the alliance!
#
# @attr coordinates [Coordinates] ({}) Storage of the X/Y Grid location.
# @attr value [Integer] (nil) The revealed value; a number (0..8)
#   representing the number of mines around this Cell.
# @attr mine [Boolean] Whether or not this Cell contains a mine.
# @attr flagged [Boolean] Whether or not this Cell has been flagged.
# @attr revealed [Boolean] Whether or not this Cell has been revealed.
# @attr highlight_origin [Boolean] Whether or not this Cell is currently the
#   origin of neighboring Cell highlights.
# @attr highlighted [Boolean] Whether or not this Cell is currently being
#   highlighted.
class Cell < ApplicationRecord # rubocop:disable Metrics/ClassLength
  self.implicit_order_column = "created_at"

  VALUES_RANGE = 0..8
  BLANK_VALUE = 0

  include ConsoleBehaviors

  belongs_to :board, inverse_of: :cells
  has_one :game, through: :board

  has_many :cell_transactions, dependent: :delete_all
  has_one :cell_reveal_transaction
  has_one :cell_chord_transaction
  has_many :cell_flag_transactions
  has_many :cell_unflag_transactions

  attribute :coordinates, CoordinatesType.new
  def x = coordinates.x
  def y = coordinates.y

  scope :for_game, ->(game) { joins(:game).merge(Game.for_id(game)) }

  scope :is_mine, -> { where(mine: true) }
  scope :is_not_mine, -> { where(mine: false) }

  validates :coordinates,
            presence: true,
            uniqueness: { scope: :board_id }
  validates :value,
            numericality: { integer: true, in: VALUES_RANGE, allow_blank: true }

  def id?(value) = to_param == value.to_s

  def toggle_flag
    toggle!(:flagged)

    self
  end

  def reveal
    return if revealed?

    soft_reveal.tap(&:save!)
  end

  # :reek:TooManyStatements

  def soft_reveal
    return if revealed?

    self.revealed = true
    self.highlighted = false
    self.flagged = false
    self.value = neighboring_mines_count

    self
  end

  def highlight_neighborhood
    return unless revealed?

    set_highlight_origin
    { self => highlight_neighbors }
  end

  def set_highlight_origin = update_column(:highlight_origin, true)

  def dehighlight_neighborhood
    return unless revealed?

    unset_highlight_origin
    { self => dehighlight_neighbors }
  end

  def unset_highlight_origin = update_column(:highlight_origin, false)

  def neighboring_flags_count_matches_value?
    neighboring_flags_count == value.to_i
  end

  def revealable_neighbors = neighbors.select(&:revealable?)
  def any_revealable_neighbors? = neighbors.any?(&:revealable?)

  def neighbors
    @neighbors ||= board&.cells_at(neighboring_coordinates).to_a
  end

  def upsertable_attributes
    attributes.except("updated_at")
  end

  def place_mine
    self.mine = true
  end

  def unrevealed? = !revealed?
  def revealable? = !(revealed? || flagged?)
  def safely_revealable? = !(mine? || revealed?)
  def incorrectly_flagged? = flagged? && !mine?
  def highlightable? = !(revealed? || flagged? || highlighted?)
  def dehighlightable? = highlighted?
  def blank? = value == BLANK_VALUE

  private

  def neighboring_coordinates = coordinates.neighbors

  def neighboring_mines_count
    @neighboring_mines_count ||= neighbors.count(&:mine?)
  end

  def neighboring_flags_count
    @neighboring_flags_count ||= neighbors.count(&:flagged?)
  end

  # @return [Array<Cell>] The Cells that were just highlighted.
  def highlight_neighbors
    neighbors.each_with_object(CompactArray.new) { |neighboring_cell, acc|
      acc << neighboring_cell.__send__(:highlight)
    }.to_a
  end

  def highlight
    return unless highlightable?

    update_column(:highlighted, true)
    self
  end

  def dehighlight_neighbors
    neighbors.each_with_object(CompactArray.new) { |neighboring_cell, acc|
      acc << neighboring_cell.__send__(:dehighlight)
    }.to_a
  end

  def dehighlight
    return unless dehighlightable?

    update_column(:highlighted, false)
    self
  end

  concerning :ObjectInspection do
    include ObjectInspectionBehaviors

    def introspect
      { self => { board => game } }
    end

    private

    def inspect_identification = identify(:id, :board_id)

    def inspect_flags(scope:)
      scope.join_flags([
        (revealed? ? Emoji.revealed_cell : Emoji.cell),
        (Emoji.flag if flagged?),
        (Emoji.mine if mine?),
        ("👁️" if highlight_origin?),
        (Emoji.eyes if highlighted?),
      ])
    end

    def inspect_issues
      if incorrectly_flagged?
        "INCORRECTLY_FLAGGED"
      elsif revealed? && mine?
        "MINE_DETONATED"
      end
    end

    def inspect_info = coordinates
    def inspect_name = value.inspect
  end

  # Cell::Console acts like a {Cell} but otherwise handles IRB Console-specific
  # methods/logic.
  class Console
    include ConsoleObjectBehaviors

    def render(cells_count: value)
      "#{current_state}#{coordinates.console.render(cells_count:)}"
    end

    private

    def current_state
      if revealed?
        highlight_origin? ? "👁️" : " #{value}"
      elsif flagged?
        Emoji.flag
      elsif highlighted?
        Emoji.eyes
      else
        Emoji.cell
      end
    end
  end
end
