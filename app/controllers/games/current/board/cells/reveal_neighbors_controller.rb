# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      updated_cells =
        # Whether we end up revealing any neighboring {Cell}s or not, we will
        # always need to dehighlight any highlighted neighboring {Cell}s as per
        # our game play rules.
        # - If neighbors are revealed, {Cell#reveal} takes care of the
        #   de-highlighting of those {Cell}s for us.
        # - Else, we must take care of this here ourselves.
        if cell.neighboring_flags_count_matches_value?
          result = Cell::RevealNeighbors.(current_context).updated_cells
          result.updated_cells
        else
          [cell, cell.dehighlight_neighbors]
        end

      WarRoomChannel.broadcast(
        Cell::TurboStream::Morph.wrap!(updated_cells, turbo_stream:))
    end

    head(:no_content)
  end
end
