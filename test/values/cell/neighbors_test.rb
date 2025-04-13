# frozen_string_literal: true

require "test_helper"

class Cell::NeighborsTest < ActiveSupport::TestCase
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
  let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }
  let(:standing_by1_board_cell4) { cells(:standing_by1_board_cell4) }
  let(:standing_by1_board_cell5) { cells(:standing_by1_board_cell5) }

  let(:standing_by1_board_cell1_neighbors) {
    Cell::Neighbors.new(cell: standing_by1_board_cell1)
  }

  describe "#to_a" do
    given "no associated Board" do
      subject { Cell::Neighbors.new(cell: Cell.new) }

      it "returns an empty collection" do
        result = subject.to_a
        _(result).must_be_empty
      end
    end

    given "an associated Board" do
      subject { standing_by1_board_cell1_neighbors }

      it "returns the expected collection of Cells" do
        result = subject.to_a
        _(result).must_match_array([
          cells(:standing_by1_board_cell2),
          cells(:standing_by1_board_cell4),
          cells(:standing_by1_board_cell5),
        ])
      end
    end
  end

  describe "#revealable?" do
    given "#any_revealable_cells? == false" do
      before do
        subject.each { it.update!(flagged: true) }
      end

      subject { standing_by1_board_cell1_neighbors }

      it "returns false" do
        _(subject.revealable?).must_equal(false)
      end
    end

    given "#any_revealable_cells? == true" do
      given "flags_count == value" do
        subject { standing_by1_board_cell1_neighbors }

        given "#value == nil" do
          it "returns true" do
            _(subject.revealable?).must_equal(true)
          end
        end

        given "#value != nil" do
          before { standing_by1_board_cell1.update!(value: 0) }

          it "returns true" do
            _(subject.revealable?).must_equal(true)
          end
        end
      end

      given "flags_count != value" do
        before { standing_by1_board_cell2.update!(flagged: true) }

        subject { standing_by1_board_cell1_neighbors }

        it "returns false" do
          _(subject.revealable?).must_equal(false)
        end
      end
    end
  end

  describe "#revealable_cells" do
    subject { standing_by1_board_cell1_neighbors }

    given "revealable Cells present" do
      before do
        MuchStub.(Cell::State, :revealable?) { true }
      end

      it "returns the expected Array of Cells" do
        _(subject.revealable_cells).must_match_array([
          standing_by1_board_cell2,
          standing_by1_board_cell4,
          standing_by1_board_cell5,
        ])
      end
    end

    given "no revealable Cells present" do
      before do
        MuchStub.(Cell::State, :revealable?) { false }
      end

      it "returns an empty Array" do
        _(subject.revealable_cells).must_equal([])
      end
    end
  end

  describe "#unrevealed_cells" do
    subject { standing_by1_board_cell1_neighbors }

    before do
      standing_by1_board_cell2.update!(revealed: true)
    end

    it "returns the expected Array of Cells" do
      _(subject.unrevealed_cells).must_equal([
        standing_by1_board_cell4,
        standing_by1_board_cell5,
      ])
    end
  end

  describe "#mines_count" do
    subject { standing_by1_board_cell1_neighbors }

    it "returns the expected Integer" do
      _(subject.mines_count).must_equal(0)
    end
  end

  describe "#highlighted_count" do
    subject { standing_by1_board_cell1_neighbors }

    it "returns the expected Integer" do
      _(subject.highlighted_count).must_equal(0)
    end
  end
end
