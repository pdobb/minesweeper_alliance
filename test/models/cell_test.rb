# frozen_string_literal: true

require "test_helper"

class CellTest < ActiveSupport::TestCase
  let(:win1_board) { boards(:win1_board) }
  let(:win1_board_cell1) { cells(:win1_board_cell1) }
  let(:win1_board_cell2) { cells(:win1_board_cell2) }
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
  let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }
  let(:standing_by1_board_cell4) { cells(:standing_by1_board_cell4) }
  let(:standing_by1_board_cell5) { cells(:standing_by1_board_cell5) }

  describe "#validate" do
    describe "#coordinates" do
      subject { Cell.new(board: win1_board, coordinates: coordinates1) }

      given "valid, unique #coordinates" do
        let(:coordinates1) { Coordinates[9, 9] }

        it "passes validation" do
          subject.validate

          _(subject.errors[:coordinates]).must_be_empty
        end
      end

      given "no #coordinates" do
        let(:coordinates1) { nil }

        it "fails validation" do
          subject.validate

          _(subject.errors[:coordinates]).must_include(
            ValidationError.presence,
          )
        end
      end

      given "non-unique #coordinates" do
        let(:coordinates1) { win1_board_cell1.coordinates }

        it "fails validation" do
          subject.validate

          _(subject.errors[:coordinates]).must_include(
            ValidationError.taken,
          )
        end
      end
    end

    describe "#value" do
      subject { Cell.new(value: value1) }

      given "a valid #value" do
        let(:value1) { Cell::VALUES_RANGE.to_a.sample }

        it "passes validation" do
          subject.validate

          _(subject.errors[:value]).must_be_empty
        end
      end

      given "a non-numeric #value" do
        let(:value1) { "IVNALID" }

        it "fails validation" do
          subject.validate

          _(subject.errors[:value]).must_include(ValidationError.numericality)
        end
      end

      given "an invalid Integer #value" do
        let(:value1) { [-1, 9].sample }

        it "fails validation" do
          subject.validate

          _(subject.errors[:value]).must_include(
            ValidationError.in(Cell::VALUES_RANGE),
          )
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
    given "an unrevealed Cell" do
      subject { standing_by1_board_cell1 }

      it "returns nil" do
        _(subject.value).must_be_nil
      end
    end

    given "a revealed Cell" do
      subject { win1_board_cell2 }

      it "returns the expected Integer" do
        _(subject.value).must_equal(1)
      end
    end

    given "a flagged Cell" do
      subject { win1_board_cell1 }

      it "returns nil" do
        _(subject.value).must_be_nil
      end
    end
  end

  describe "#upsertable_attributes" do
    subject { Cell.new }

    it "returns the expected Hash" do
      _(subject.upsertable_attributes.keys).wont_include("updated_at")
    end
  end

  describe "#place_mine" do
    given "#mine = false" do
      subject { Cell.new }

      it "sets #mine = true" do
        _(-> { subject.place_mine }).must_change(
          "subject.mine", from: false, to: true
        )
      end
    end
  end
end
