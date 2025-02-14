# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  rate_limit to: 3, within: 1.second

  def create
    updated_cells = cell.soft_highlight_neighborhood
    turbo_stream_actions =
      Cell::TurboStream::Morph.wrap_and_call(updated_cells, turbo_stream:)

    WarRoom::Responder.new(context: self).(turbo_stream_actions:)
  end

  private

  def cell = Cell.find(params[:cell_id])
end
