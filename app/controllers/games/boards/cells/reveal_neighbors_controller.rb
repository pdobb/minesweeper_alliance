# frozen_string_literal: true

class Games::Boards::Cells::RevealNeighborsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    RevealNeighbors.(game:, board:, cell:)

    broadcast_changes
    render_updated_game_board
  end

  # Games::Boards::Cells::RevealNeighborsController::RevealNeighbors is a
  # Service Object for collaborating with {Game}, {Board}, and {Cell} to
  # process a {Cell} "Reveal Neighbors" event. In order for processing to
  # proceed:
  # - The given, originating {Cell} must have been previously revealed, and
  # - The number of flagged neighboring {Cell}s must match the given {Cell}'s
  #   {Cell#value}.
  #
  # This service is a convenience. We're saving the player time by just going
  # ahead and revealing all of the non-flagged (and non-revealed) neighboring
  # cells to the given, originating {Cell}. Also, if doing so reveals a Blank
  # {Cell}, then we'll recursively reveal its neighboring {Cell}s, and so on.
  #
  # Whether we end up revealing any neighboring {Cell}s or not, we also will
  # always need to dehighlight any highlighted, neighboring {Cell}s as per our
  # game play rules. (Which {Cell#reveal} also does.)
  #
  # Notes:
  # - If this operation results in a win or loss, we need to react to that.
  # - Revealing neighbors doesn't guarantee success. If any of the flags are
  #   incorrectly placed a mine could still go off!
  class RevealNeighbors
    include CallMethodBehaviors

    attr_reader :game,
                :board,
                :cell

    def initialize(game:, board:, cell:)
      @game = game
      @board = board
      @cell = cell
    end

    def on_call
      return self if unrevealed?

      recursively_reveal_neighbors_if_neighboring_flags_count_matches_value
      end_game_in_victory_if_all_safe_cells_revealed

      self
    end

    private

    def unrevealed?
      cell.unrevealed?
    end

    def recursively_reveal_neighbors_if_neighboring_flags_count_matches_value
      if cell.neighboring_flags_count_matches_value?
        Recurse.(game:, cell:)
      else
        cell.dehighlight_neighbors
      end
    end

    def end_game_in_victory_if_all_safe_cells_revealed
      board.check_for_victory
    end

    # Games::Boards::Cells::RevealNeighborsController::RevealNeighbors::Recurse
    # is a Service Object for collaborating with the given {Game} to reveal the
    # given {Cell}. If the {Cell} we just revealed was {Cell#blank?}, then we
    # will also recursively reveal its neighboring {Cell}s, as per usual.
    #
    # Notes:
    # - We don't just recurse with
    #   {Games::Boards::Cells::RevealNeighborsController::RevealNeighbors}
    #   because at this point {Cell#neighboring_flags_count_matches_value?}
    #   doesn't matter. We're just revealing neighbors if the current {Cell} was
    #   {Cell#blank?}, as per usual.
    # - We don't just use {Games::Boards::Cells::RevealsController::Reveal} for
    #   this because we don't want or need to spend time checking on {Board}
    #   state while recursing. Plus, we do, in this case, need to check for
    #   mines on neighboring {Cell}s and end the {Game} early if one was
    #   revealed (due to incorrect flag placement).
    class Recurse
      include CallMethodBehaviors

      attr_reader :game,
                  :cell

      def initialize(game:, cell:)
        @game = game
        @cell = cell
      end

      def on_call
        catch(:return) {
          arel.each do |neighboring_cell|
            reveal(neighboring_cell)
            recurse(neighboring_cell)
          end

          self
        }
      end

      private

      def arel
        cell.neighbors.is_not_flagged.is_not_revealed
      end

      def reveal(neighboring_cell)
        neighboring_cell.reveal

        if neighboring_cell.mine? # rubocop:disable Style/GuardClause
          game.end_in_defeat

          throw(:return, self)
        end
      end

      def recurse(neighboring_cell)
        if neighboring_cell.blank? # rubocop:disable Style/GuardClause
          self.class.(game:, cell: neighboring_cell)
        end
      end
    end
  end
end
