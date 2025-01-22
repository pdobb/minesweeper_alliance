# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    updated_cells =
      safe_perform_game_action {
        # Whether we end up revealing any neighboring {Cell}s or not, we will
        # always need to dehighlight any highlighted neighboring {Cell}s as per
        # our game play rules.
        # - If neighbors are revealed, {Cell#reveal} takes care of the
        #   de-highlighting of those {Cell}s for us.
        # - Else, we must take care of this here ourselves.
        if cell.neighboring_flags_count_matches_value?
          Cell::RevealNeighbors.(current_context).updated_cells
        else
          cell.dehighlight_neighbors
        end
      }

    broadcast_updates([cell, updated_cells])
  end
end
