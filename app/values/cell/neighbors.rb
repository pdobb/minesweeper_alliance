# frozen_string_literal: true

# Cell::Neighbors represents the collection of neighboring {Cell}s for the
# given {Cell}, which is based on the corresponding {Coordinates#neighbors}.
class Cell::Neighbors
  extend Forwardable

  include Enumerable

  def_delegators(:array, *%i[
    []
    each
    empty?
    first
    include?
    last
    size
    to_a
    to_ary
    uniq!
  ])

  def initialize(cell:)
    @cell = cell
    @array = board&.cells_at(neighboring_coordinates).to_a
    freeze
  end

  def revealable? = any_revealable_cells? && flags_count_matches_value?
  def revealable_cells = select { Cell::State.revealable?(it) }
  def unrevealed_cells = reject(&:revealed?)

  def mines_count = count(&:mine?)
  def highlighted_count = count(&:highlighted?)

  private

  attr_reader :cell,
              :array

  def board = cell.board
  def coordinates = cell.coordinates
  def neighboring_coordinates = coordinates.neighbors
  def value = cell.value

  def any_revealable_cells? = revealable_cells.any?
  def flags_count_matches_value? = flags_count == value.to_i
  def flags_count = count(&:flagged?)
end
