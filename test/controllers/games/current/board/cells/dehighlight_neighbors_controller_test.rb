# frozen_string_literal: true

require "test_helper"

class Games::Current::Board::Cells::DehighlightNeighborsControllerTest <
        ActionDispatch::IntegrationTest
  describe "#create" do
    let(:game) { games(:standing_by1) }
    let(:board) { boards(:standing_by1_board) }
    let(:cell) { cells(:standing_by1_board_cell1) }
    let(:neighbor) { cells(:standing_by1_board_cell2) }

    before do
      # Cell::Find binary-searches ids, so created_at order has to follow id.
      board.cells.sort_by(&:id).each_with_index do |ordered_cell, index|
        ordered_cell.update_columns(created_at: Time.zone.at(index))
      end
      Cell::Reveal.(cell)
      Cell::HighlightNeighborhood.(cell)
    end

    it "clears the highlight in the snapshot it broadcasts" do
      post(
        game_board_cell_dehighlight_neighbors_path(game, cell),
        as: :turbo_stream,
      )

      _(response.status).must_equal(200)
      _(response.body).must_include('data-version="1"')
      _(response.body).wont_include("animate-pulse-fast")
      _(response.body).wont_include("text-blue-500")
      _(cell.reload.highlight_origin?).must_equal(false)
      _(neighbor.reload.highlighted?).must_equal(false)
      _(board.reload.version).must_equal(1)
    end
  end
end
