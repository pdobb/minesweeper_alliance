# frozen_string_literal: true

require "test_helper"

class Cell::HighlightNeighborhoodTest < ActiveSupport::TestCase
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
  let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }
  let(:standing_by1_board_cell4) { cells(:standing_by1_board_cell4) }
  let(:standing_by1_board_cell5) { cells(:standing_by1_board_cell5) }

  describe ".call" do
    subject { Cell::HighlightNeighborhood }

    given "an unrevealed Cell" do
      let(:cell1) { standing_by1_board_cell1 }

      it "returns nil" do
        result =
          _(-> { subject.call(cell1) }).wont_change(
            "Cell::Neighbors.new(cell: cell1).highlighted_count",
          )

        _(result).must_be_nil
      end
    end

    given "a revealed Cell with unhighlighted neighbors" do
      before do
        Cell::Reveal.(cell1)
      end

      let(:cell1) { standing_by1_board_cell1 }

      it "highlights the expected Cells, and returns them" do
        result =
          _(-> { subject.call(cell1) }).must_change_all([
            ["cell1.highlight_origin?", { to: true }],
            [
              "Cell::Neighbors.new(cell: cell1).highlighted_count",
              { from: 0, to: 3 },
            ],
          ])

        origin, neighbors = result.to_a.first

        _(origin).must_be_same_as(cell1)
        _(neighbors).must_match_array([
          standing_by1_board_cell2,
          standing_by1_board_cell4,
          standing_by1_board_cell5,
        ])
      end
    end
  end
end
