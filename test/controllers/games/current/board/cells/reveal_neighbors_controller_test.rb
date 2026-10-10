# frozen_string_literal: true

require "test_helper"

class Games::Current::Board::Cells::RevealNeighborsControllerTest <
        ActionDispatch::IntegrationTest
  describe "#create" do
    let(:game) { games(:standing_by1) }
    let(:board) { boards(:standing_by1_board) }
    let(:cell) { cells(:standing_by1_board_cell1) }
    let(:neighbor) { cells(:standing_by1_board_cell2) }

    given "the revealed cell is not ready to chord" do
      before do
        # Cell::Find binary-searches ids, so created_at order has to follow id.
        board.cells.sort_by(&:id).each_with_index do |ordered_cell, index|
          ordered_cell.update_columns(created_at: Time.zone.at(index))
        end
        Cell::Reveal.(cell)
        cell.update_column(:value, 1)
        Cell::HighlightNeighborhood.(cell)
      end

      it "dehighlights instead of revealing neighbors" do
        post(
          game_board_cell_reveal_neighbors_path(game, cell),
          as: :turbo_stream,
        )

        _(response.status).must_equal(200)
        _(response.body).must_include('data-version="1"')
        _(response.body).wont_include("animate-pulse-fast")
        _(response.body).wont_include("text-blue-500")
        _(cell.reload.highlight_origin?).must_equal(false)
        _(neighbor.reload.highlighted?).must_equal(false)
        _(neighbor.reload.revealed?).must_equal(false)
        _(board.reload.version).must_equal(1)
      end
    end

    given "the game is over and the cell can chord" do
      let(:game) { games(:loss1) }
      let(:board) { boards(:loss1_board) }
      let(:cell) { cells(:loss1_board_cell1) }

      before do
        board.cells.sort_by(&:id).each_with_index do |ordered_cell, index|
          ordered_cell.update_columns(created_at: Time.zone.at(index))
        end
      end

      it "refreshes the page" do
        post(
          game_board_cell_reveal_neighbors_path(game, cell),
          as: :turbo_stream,
        )

        _(response.status).must_equal(200)
        _(response.body).must_include('action="refresh"')
      end
    end

    given "the game is over and the cell cannot chord" do
      let(:game) { games(:loss1) }
      let(:board) { boards(:loss1_board) }
      let(:cell) { cells(:loss1_board_cell5) }

      before do
        board.cells.sort_by(&:id).each_with_index do |ordered_cell, index|
          ordered_cell.update_columns(created_at: Time.zone.at(index))
        end
        Cell::Reveal.(cell)
        cell.update_column(:value, 1)
      end

      it "refreshes the page" do
        post(
          game_board_cell_reveal_neighbors_path(game, cell),
          as: :turbo_stream,
        )

        _(response.status).must_equal(200)
        _(response.body).must_include('action="refresh"')
      end
    end
  end
end
