# frozen_string_literal: true

require "test_helper"

class CellTest < ActiveSupport::TestCase
  describe "Cell" do
    let(:unit_class) { Cell }

    let(:win1_board) { boards(:win1_board) }
    let(:win1_board_cell1) { cells(:win1_board_cell1) }
    let(:win1_board_cell2) { cells(:win1_board_cell2) }
    let(:win1_board_cell3) { cells(:win1_board_cell3) }
    let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
    let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }
    let(:standing_by1_board_cell4) { cells(:standing_by1_board_cell4) }
    let(:standing_by1_board_cell5) { cells(:standing_by1_board_cell5) }

    describe "#validate" do
      describe "#coordinates" do
        subject { unit_class.new(board: win1_board, coordinates: coordinates1) }

        context "GIVEN valid, unique #coordinates" do
          let(:coordinates1) { Coordinates[9, 9] }

          it "passes validation" do
            subject.validate
            _(subject.errors[:coordinates]).must_be_empty
          end
        end

        context "GIVEN no #coordinates" do
          let(:coordinates1) { nil }

          it "fails validation" do
            subject.validate
            _(subject.errors[:coordinates]).must_include(
              ValidationError.presence)
          end
        end

        context "GIVEN non-unique #coordinates" do
          let(:coordinates1) { win1_board_cell1.coordinates }

          it "fails validation" do
            subject.validate
            _(subject.errors[:coordinates]).must_include(
              ValidationError.taken)
          end
        end
      end

      describe "#value" do
        subject { unit_class.new(value: value1) }

        context "GIVEN a valid #value" do
          let(:value1) { Cell::VALUES_RANGE.to_a.sample }

          it "passes validation" do
            subject.validate
            _(subject.errors[:value]).must_be_empty
          end
        end

        context "GIVEN a non-numeric #value" do
          let(:value1) { "IVNALID" }

          it "fails validation" do
            subject.validate
            _(subject.errors[:value]).must_include(ValidationError.numericality)
          end
        end

        context "GIVEN an invalid Integer #value" do
          let(:value1) { [-1, 9].sample }

          it "fails validation" do
            subject.validate
            _(subject.errors[:value]).must_include(
              ValidationError.in(Cell::VALUES_RANGE))
          end
        end
      end
    end

    describe "#coordinates" do
      subject { win1_board_cell1 }

      it "returns a Coordinates" do
        _(subject.coordinates).must_be_instance_of(Coordinates)
      end
    end

    describe "#x" do
      subject { win1_board_cell1 }

      it "returns the expected Integer" do
        _(subject.x).must_equal(0)
      end
    end

    describe "#y" do
      subject { win1_board_cell1 }

      it "returns the expected Integer" do
        _(subject.y).must_equal(0)
      end
    end

    describe "#value" do
      context "GIVEN an unrevealed Cell" do
        subject { standing_by1_board_cell1 }

        it "returns nil" do
          _(subject.value).must_be_nil
        end
      end

      context "GIVEN a revealed Cell" do
        subject { win1_board_cell2 }

        it "returns the expected Integer" do
          _(subject.value).must_equal(1)
        end
      end

      context "GIVEN a flagged Cell" do
        subject { win1_board_cell1 }

        it "returns nil" do
          _(subject.value).must_be_nil
        end
      end
    end

    describe "#toggle_flag" do
      context "GIVEN #flagged was previously falsey" do
        subject { standing_by1_board_cell1 }

        it "sets #flagged to true" do
          _(-> { subject.toggle_flag }).must_change(
            "subject.flagged?", to: true)
        end
      end

      context "GIVEN #flagged was previously truthy" do
        before do
          subject.update!(flagged: true)
        end

        subject { standing_by1_board_cell1 }

        it "sets #flagged to false" do
          _(-> { subject.toggle_flag }).must_change(
            "subject.flagged?", to: false)
        end
      end
    end

    describe "#reveal" do
      context "GIVEN an already revealed Cell" do
        before do
          standing_by1_board_cell1.reveal
        end

        subject { standing_by1_board_cell1 }

        it "returns nil" do
          result =
            _(-> { subject.reveal }).wont_change_all([
              ["subject.highlighted"],
              ["subject.flagged"],
              ["subject.value"],
            ])
          _(result).must_be_nil
        end
      end

      context "GIVEN an unrevealed, highlighted, and flagged Cell" do
        before do
          subject.update!(highlighted: true, flagged: true)
        end

        subject { standing_by1_board_cell1 }

        it "updates itself as expected, and returns self" do
          result =
            _(-> { subject.reveal }).must_change_all([
              ["subject.revealed", to: true],
              ["subject.highlighted", to: false],
              ["subject.flagged", to: false],
              ["subject.value"],
            ])
          _(result).must_be_same_as(subject)
        end
      end
    end

    describe "#highlight_neighbors" do
      context "GIVEN an unrevealed Cell" do
        subject { standing_by1_board_cell1 }

        it "returns self without having updated it" do
          result =
            _(-> { subject.dehighlight_neighbors }).wont_change(
              "subject.neighbors.count(&:highlighted?)")
          _(result).must_be_same_as(subject)
        end
      end

      context "GIVEN a revealed Cell with unhighlighted neighbors" do
        before do
          subject.reveal
        end

        subject { standing_by1_board_cell1 }

        it "highlights the expected Cells, and returns them" do
          result =
            _(-> { subject.highlight_neighbors }).must_change(
              "subject.neighbors.count(&:highlightable?)",
              to: 0)
          _(result).must_match_array([
            standing_by1_board_cell2,
            standing_by1_board_cell4,
            standing_by1_board_cell5,
          ])
        end
      end
    end

    describe "#dehighlight_neighbors" do
      subject { standing_by1_board_cell1 }

      context "GIVEN an unrevealed Cell" do
        subject { standing_by1_board_cell1 }

        it "returns self without having updated it" do
          result =
            _(-> { subject.dehighlight_neighbors }).wont_change(
              "subject.neighbors.count(&:highlighted?)")
          _(result).must_be_same_as(subject)
        end
      end

      context "GIVEN a revealed Cell with highlighted neighbors" do
        before do
          subject.reveal.highlight_neighbors
        end

        subject { standing_by1_board_cell1 }

        it "dehighlights the expected Cells, and returns them" do
          result =
            _(-> { subject.dehighlight_neighbors }).must_change(
              "subject.neighbors.count(&:highlighted?)", to: 0)
          _(result).must_match_array([
            standing_by1_board_cell2,
            standing_by1_board_cell4,
            standing_by1_board_cell5,
          ])
        end
      end
    end

    describe "#neighboring_flags_count_matches_value?" do
      context "GIVEN neighboring_flags_count == value" do
        subject { standing_by1_board_cell1 }

        context "GIVEN #value == nil" do
          it "returns true" do
            _(subject.neighboring_flags_count_matches_value?).must_equal(true)
          end
        end

        context "GIVEN #value != nil" do
          before do
            subject.update!(value: 0)
          end

          it "returns true" do
            _(subject.neighboring_flags_count_matches_value?).must_equal(true)
          end
        end
      end

      context "GIVEN neighboring_flags_count != value" do
        before do
          standing_by1_board_cell2.update!(flagged: true)
        end

        subject { standing_by1_board_cell1 }

        it "returns false" do
          _(subject.neighboring_flags_count_matches_value?).must_equal(false)
        end
      end
    end

    describe "#neighbors" do
      context "GIVEN no associated Board" do
        subject { unit_class.new }

        it "returns an empty Array" do
          result = subject.neighbors
          _(result).must_be_empty
        end
      end

      context "GIVEN an associated Board" do
        subject { standing_by1_board_cell1 }

        it "returns the expected Array of Cells" do
          result = subject.neighbors

          _(result).must_equal([
            cells(:standing_by1_board_cell2),
            cells(:standing_by1_board_cell4),
            cells(:standing_by1_board_cell5),
          ])
        end
      end
    end

    describe "#upsertable_attributes" do
      subject { unit_class.new }

      it "returns the expected Hash" do
        _(subject.upsertable_attributes.keys).wont_include("updated_at")
      end
    end

    describe "#place_mine" do
      context "GIVEN #mine = false" do
        subject { unit_class.new }

        it "sets #mine = true" do
          _(-> { subject.place_mine }).must_change(
            "subject.mine", from: false, to: true)
        end
      end
    end

    describe "#unrevealed?" do
      context "GIVEN #revealed? == false" do
        subject { win1_board_cell1 }

        it "returns true" do
          _(subject.unrevealed?).must_equal(true)
        end
      end

      context "GIVEN #revealed? == true" do
        subject { win1_board_cell2 }

        it "returns false" do
          _(subject.unrevealed?).must_equal(false)
        end
      end
    end

    describe "#blank?" do
      context "GIVEN #value == '0'" do
        subject { win1_board_cell3 }

        it "returns true" do
          _(subject.blank?).must_equal(true)
        end
      end

      context "GIVEN #value != '0'" do
        subject { win1_board_cell2 }

        it "returns false" do
          _(subject.blank?).must_equal(false)
        end
      end

      context "GIVEN #value == nil" do
        subject { standing_by1_board_cell1 }

        it "returns false" do
          _(subject.blank?).must_equal(false)
        end
      end
    end

    describe "#incorrectly_flagged?" do
      context "GIVEN #flagged? = true" do
        subject { win1_board_cell1 }

        context "GIVEN #mine? = true" do
          it "returns false" do
            _(subject.incorrectly_flagged?).must_equal(false)
          end
        end

        context "GIVEN #mine? = false" do
          before do
            subject.update!(mine: false)
          end

          it "returns true" do
            _(subject.incorrectly_flagged?).must_equal(true)
          end
        end
      end

      context "GIVEN #flagged? = false" do
        subject { win1_board_cell2 }

        it "returns false" do
          _(subject.incorrectly_flagged?).must_equal(false)
        end
      end
    end
  end
end
