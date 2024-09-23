# frozen_string_literal: true

class Games::Boards::Cells::RevealsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    Reveal.(current_context)

    broadcast_changes
    render_updated_game_board
  end

  # Games::Boards::Cells::RevealsController::Reveal is a Service Object for
  # collaborating with {Game}, {Board}, and {Cell} to process a {Cell} "Reveal"
  # event. This involves:
  # - "Starting" the {Game}, if it hasn't already been
  # - Actually calling {Cell#reveal} (of course)
  # - "Ending" the {Game} early if the {Cell} we just revealed was a mine
  # - Recursively revealing neighboring {Cell}s if the {Cell} we just revealed
  #   was Blank
  # - "Ending" the {Game} in victory if all safe {Cell}s on the {Board} have
  #   just been revealed
  class Reveal
    include CallMethodBehaviors

    attr_reader :game,
                :board,
                :cell,
                :user

    def initialize(context)
      @game = context.game
      @board = context.board
      @cell = context.cell
      @user = context.user
    end

    # :reek:TooManyStatements

    def on_call
      return self if already_revealed?

      catch(:return) {
        start_game_if_standing_by
        reveal_cell
        end_game_in_defeat_if_mine_revealed
        recursively_reveal_neighbors_if_revealed_cell_was_blank
        end_game_in_victory_if_all_safe_cells_revealed

        self
      }
    end

    private

    def already_revealed?
      cell.revealed?
    end

    def start_game_if_standing_by
      game.start(seed_cell: cell)
    end

    def reveal_cell
      cell.transaction do
        cell.reveal
        CellRevealTransaction.create_between(user:, cell:)
      end
    end

    def end_game_in_defeat_if_mine_revealed
      return unless cell.mine?

      game.end_in_defeat
      throw(:return, self)
    end

    def recursively_reveal_neighbors_if_revealed_cell_was_blank
      return unless cell.blank? # rubocop:disable all

      upsertable_attributes_array =
        Games::Boards::Cells::RecursiveReveal.new(cell:).call
      Cell.upsert_all(upsertable_attributes_array)
    end

    def end_game_in_victory_if_all_safe_cells_revealed
      board.check_for_victory
    end
  end
end
