# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      updated_cells = cell.highlight_neighbors

      WarRoomChannel.broadcast(
        Cell::TurboStream::Morph.wrap!([cell, updated_cells], turbo_stream:))
    end

    head(:no_content)
  end
end
