# frozen_string_literal: true

require "test_helper"

class GridTest < ActiveSupport::TestCase
  describe "Grid" do
    let(:unit_class) { Grid }

    let(:transposing_context1) {
      Class.new { def transpose? = true }.new
    }
    let(:non_transposing_context1) {
      Class.new { def transpose? = false }.new
    }

    let(:cells_array1) { [Coordinates[0, 0], Coordinates[1, 0]] }
    let(:coordinates1) { Coordinates[9, 9] }

    describe "#cells" do
      context "GIVEN a Cell" do
        subject { unit_class.new(coordinates1) }

        it "returns the expected Array" do
          _(subject.cells).must_equal([coordinates1])
        end
      end

      context "GIVEN an Array of Cells" do
        subject { unit_class.new(cells_array1) }

        it "returns the expected Array" do
          _(subject.cells).must_equal(cells_array1)
        end
      end
    end

    describe "#cells_count" do
      subject { unit_class.new([coordinates1]) }

      it "returns the expected Integer" do
        _(subject.cells_count).must_equal(1)
      end
    end

    describe "#columns_count" do
      subject { unit_class.new(cells_array1) }

      it "returns the expected Integer" do
        _(subject.columns_count).must_equal(2)
      end
    end

    describe "#to_h" do
      context "GIVEN Cell#y is not nil" do
        subject { unit_class.new([coordinates1]) }

        it "returns the expected Hash" do
          _(subject.to_h).must_equal({ 9 => [coordinates1] })
        end
      end

      context "GIVEN Cell#y is nil" do
        subject { unit_class.new([Coordinates[nil, nil]]) }

        it "returns the expected Hash" do
          _(subject.to_h).must_equal({ "nil" => [Coordinates[nil, nil]] })
        end
      end
    end

    describe "#to_a" do
      subject { unit_class.new(cells_array1, context:) }

      context "GIVEN a transposing context" do
        let(:context) { transposing_context1 }

        it "returns the expected, transposed Array" do
          _(subject.to_a).must_equal([
            [Coordinates[0, 0]],
            [Coordinates[1, 0]],
          ])
        end
      end

      context "GIVEN a non-transposing context" do
        let(:context) { non_transposing_context1 }

        it "returns the expected, non-transposed Array" do
          _(subject.to_a).must_equal([cells_array1])
        end
      end
    end

    describe "#map" do
      subject { unit_class.new([coordinates1]) }

      it "returns an enumerator, GIVEN no block" do
        _(subject.map).must_be_instance_of(Enumerator)
      end

      it "returns the expected mapping, GIVEN a block" do
        result = subject.map { |array| array.map(&:y) }
        _(result).must_equal([[9]])
      end
    end
  end
end
