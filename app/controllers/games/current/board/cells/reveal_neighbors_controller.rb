# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    # We must always dehighlight any highlighted {Cell}s, as per our game play
    # rules.
    # - If neighbors are being revealed here, {Cell#reveal} takes care of this.
    # - Else, we appeal to {Games::Current::Board::Cells::DehighlightNeighbors}
    #   to revert any highlighted {Cell}s back to their default state.
    if cell.neighboring_flags_count_matches_value?
      require_participant

      updated_cells = Cell::RevealNeighbors.(context).updated_cells
      broadcast_updates(updated_cells)
    else
      Games::Current::Board::Cells::DehighlightNeighbors.(context: self)
    end
  end
end
