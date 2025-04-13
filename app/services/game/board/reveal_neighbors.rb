# frozen_string_literal: true

# :reek:TooManyInstanceVariables

# Game::Board::RevealNeighbors is a Service Object for collaborating with a
# {Game}, {Board}, and {Cell} to process a {Cell} "Reveal Neighbors" event
# (a.k.a. "chording"). Prerequisites for processing:
# - The given, originating {Cell} must have been previously revealed, and
# - The number of flagged neighboring {Cell}s must match the given {Cell}'s
#   {Cell#value}.
#
# In the grand scheme this service is basically just a convenience. i.e. We're
# saving the player time by just going ahead and revealing all of the
# non-flagged (and non-revealed) neighboring {Cell}s of the given, originating
# {Cell}. Also, if doing so reveals a Blank {Cell}, then we'll recursively
# reveal its neighboring {Cell}s, as per usual.
#
# Notes:
# - If this operation results in a Game Win or Loss, we need to capture that.
# - Revealing neighbors doesn't guarantee success. If any of the flags are
#   incorrectly placed a mine could still go off!
#
# @see Game::Board::RecursiveReveal
class Game::Board::RevealNeighbors
  def self.call(...) = new(...).call

  def initialize(context:)
    @game = context.game
    @board = context.board
    @cell = context.cell
    @user = context.user
  end

  # :reek:TooManyStatements

  def call
    return self if Cell::State.unrevealed?(cell)

    catch(:return) {
      game.with_lock do
        reveal_neighbors
        end_game_in_victory_if_all_safe_cells_revealed
      end

      self
    }
  end

  private

  attr_reader :game,
              :board,
              :cell,
              :user

  # :reek:TooManyStatements
  def reveal_neighbors
    return if revealable_neighboring_cells.none?

    cell.transaction do
      CellChordTransaction.create_between(user:, cell:)
      ParticipantTransaction.activate_between(user:, game:)

      unset_highlight_origin
      revealable_neighboring_cells.each do |neighboring_cell|
        reveal_neighbor(neighboring_cell)
      end
    end
  end

  def unset_highlight_origin
    cell.unset_highlight_origin
  end

  def revealable_neighboring_cells
    @revealable_neighboring_cells ||= neighbors.revealable_cells
  end

  def neighbors = @neighbors ||= Cell::Neighbors.new(cell:)

  def reveal_neighbor(neighboring_cell)
    reveal(neighboring_cell)
    return unless Cell::State.blank?(neighboring_cell) # rubocop:disable all

    recursively_reveal_neighbors(neighboring_cell)
  end

  # :reek:FeatureEnvy
  def reveal(neighboring_cell)
    Cell::Reveal.(neighboring_cell)

    end_in_defeat(user:) if neighboring_cell.mine?
  end

  def end_in_defeat(user:)
    game.end_in_defeat(user:)
    throw(:return, self)
  end

  def recursively_reveal_neighbors(neighboring_cell)
    upsertable_attributes_array =
      Game::Board::RecursiveReveal.(neighboring_cell)
    Cell.upsert_all(upsertable_attributes_array)
  end

  def end_game_in_victory_if_all_safe_cells_revealed
    board.check_for_victory(user:)
  end
end
