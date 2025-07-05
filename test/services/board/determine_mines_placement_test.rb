# frozen_string_literal: true

require "test_helper"

class Board::DetermineMinesPlacementTest < ActiveSupport::TestCase
  let(:standing_by1_board) { boards(:standing_by1_board) }

  describe ".call" do
    let(:board1) { standing_by1_board }

    subject { Board::DetermineMinesPlacement }

    given "a Pattern board" do
      before do
        MuchStub.(board1, :settings) {
          Board::Settings.pattern("Test Pattern 1")
        }
      end

      it "calls Board::PlaceMines" do
        MuchStub.(Board::PlaceMines, :call) { @place_mines_called = true }
        subject.call(board: board1, seed_cell: nil)

        _(@place_mines_called).must_equal(true)
      end
    end

    given "a non-Pattern board" do
      it "calls Board::RandomlyPlaceMines" do
        MuchStub.(Board::RandomlyPlaceMines, :call) {
          @randomly_place_mines_called = true
        }
        subject.call(board: board1, seed_cell: nil)

        _(@randomly_place_mines_called).must_equal(true)
      end
    end
  end
end
