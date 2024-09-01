# frozen_string_literal: true

require "test_helper"

class GridTest < ActiveSupport::TestCase
  describe "Grid" do
    let(:unit_class) { Grid }

    describe "#cells" do
      context "GIVEN an Array of Cells" do
        subject { unit_class.new([1, 2, 3]) }

        it "returns the expected Array" do
          value(subject.cells).must_equal([1, 2, 3])
        end
      end

      context "GIVEN a Cell" do
        subject { unit_class.new(1) }

        it "returns the expected Array" do
          value(subject.cells).must_equal([1])
        end
      end
    end

    describe "#to_h" do
      context "GIVEN Cell#y is not nil" do
        subject { unit_class.new([Coordinates[9, 9]]) }

        it "returns the expected Hash" do
          value(subject.to_h).must_equal({ 9 => [Coordinates[9, 9]] })
        end
      end

      context "GIVEN Cell#y is nil" do
        subject { unit_class.new([Coordinates[nil, nil]]) }

        it "returns the expected Hash" do
          value(subject.to_h).must_equal({ "nil" => [Coordinates[nil, nil]] })
        end
      end
    end

    describe "#to_a" do
      subject { unit_class.new([Coordinates[9, 9]]) }

      it "returns the expected Array" do
        value(subject.to_a).must_equal([[Coordinates[9, 9]]])
      end
    end

    describe "#count" do
      subject { unit_class.new([Coordinates[9, 9]]) }

      it "returns the expected Integer" do
        value(subject.count).must_equal(1)
      end
    end
  end
end
