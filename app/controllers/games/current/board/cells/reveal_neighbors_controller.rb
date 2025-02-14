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
      cell = Cell.find(params[:cell_id])
      updated_cells = cell.highlightable_neighborhood
      turbo_stream_actions =
        Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:)

      WarRoom::Responder.new(context: self).(turbo_stream_actions:)
    end
  end
end
