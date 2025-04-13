# frozen_string_literal: true

require "test_helper"

class Cell::StateTest < ActiveSupport::TestCase
  let(:unit_class) { Cell::State }

  let(:win1_board_cell1) { cells(:win1_board_cell1) }
  let(:win1_board_cell2) { cells(:win1_board_cell2) }
  let(:win1_board_cell3) { cells(:win1_board_cell3) }
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }

  describe ".unrevealed?" do
    subject { unit_class }

    given "Cell#revealed? == false" do
      it "returns true" do
        _(subject.unrevealed?(win1_board_cell1)).must_equal(true)
      end
    end

    given "Cell#revealed? == true" do
      it "returns false" do
        _(subject.unrevealed?(win1_board_cell2)).must_equal(false)
      end
    end
  end

  describe ".revealable?" do
    subject { unit_class }

    given "Cell#revealed? == true" do
      it "returns false" do
        _(subject.revealable?(win1_board_cell2)).must_equal(false)
      end
    end

    given "Cell#revealed? == false" do
      given "Cell#flagged? == true" do
        it "returns false" do
          _(subject.revealable?(win1_board_cell1)).must_equal(false)
        end
      end

      given "Cell#flagged? == false" do
        it "returns true" do
          _(subject.revealable?(standing_by1_board_cell1)).must_equal(true)
        end
      end
    end
  end

  describe ".safely_revealable?" do
    subject { unit_class }

    given "Cell#mine? == true" do
      it "returns false" do
        _(subject.safely_revealable?(win1_board_cell1)).must_equal(false)
      end
    end

    given "Cell#mine? == false" do
      given "Cell#revealed? == true" do
        it "returns false" do
          _(subject.safely_revealable?(win1_board_cell2)).must_equal(false)
        end
      end

      given "Cell#revealed? == false" do
        it "returns true" do
          _(subject.safely_revealable?(standing_by1_board_cell1))
            .must_equal(true)
        end
      end
    end
  end

  describe ".incorrectly_flagged?" do
    subject { unit_class }

    given "Cell#flagged? = true" do
      given "Cell#mine? = true" do
        it "returns false" do
          _(subject.incorrectly_flagged?(win1_board_cell1)).must_equal(false)
        end
      end

      given "Cell#mine? = false" do
        before do
          win1_board_cell1.update!(mine: false)
        end

        it "returns true" do
          _(subject.incorrectly_flagged?(win1_board_cell1)).must_equal(true)
        end
      end
    end

    given "Cell#flagged? = false" do
      it "returns false" do
        _(subject.incorrectly_flagged?(win1_board_cell2)).must_equal(false)
      end
    end
  end

  describe ".blank?" do
    subject { unit_class }

    given "Cell#value == '0'" do
      it "returns true" do
        _(subject.blank?(win1_board_cell3)).must_equal(true)
      end
    end

    given "Cell#value != '0'" do
      it "returns false" do
        _(subject.blank?(win1_board_cell2)).must_equal(false)
      end
    end

    given "Cell#value == nil" do
      it "returns false" do
        _(subject.blank?(standing_by1_board_cell1)).must_equal(false)
      end
    end
  end

  describe ".highlightable?" do
    subject { unit_class }

    given "Cell#revealed? == Cell#flagged? == Cell#highlighted? == false" do
      it "returns true" do
        _(subject.highlightable?(standing_by1_board_cell1)).must_equal(true)
      end
    end

    given "Cell#revealed? == true" do
      before do
        standing_by1_board_cell1.update_column(:revealed, true)
      end

      it "returns false" do
        _(subject.highlightable?(standing_by1_board_cell1)).must_equal(false)
      end
    end

    given "Cell#flagged? == true" do
      before do
        standing_by1_board_cell1.update_column(:flagged, true)
      end

      it "returns false" do
        _(subject.highlightable?(standing_by1_board_cell1)).must_equal(false)
      end
    end

    given "Cell#highlighted? == true" do
      before do
        standing_by1_board_cell1.update_column(:highlighted, true)
      end

      it "returns false" do
        _(subject.highlightable?(standing_by1_board_cell1)).must_equal(false)
      end
    end
  end

  describe ".dehighlightable?" do
    subject { unit_class }

    given "Cell#highlighted? == true" do
      before do
        standing_by1_board_cell1.update_column(:highlighted, true)
      end

      it "returns true" do
        _(subject.dehighlightable?(standing_by1_board_cell1)).must_equal(true)
      end
    end

    given "Cell#highlighted? == false" do
      it "returns false" do
        _(subject.dehighlightable?(standing_by1_board_cell1)).must_equal(false)
      end
    end
  end
end
