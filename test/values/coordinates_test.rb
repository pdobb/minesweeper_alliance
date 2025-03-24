# frozen_string_literal: true

require "test_helper"

class CoordinatesTest < ActiveSupport::TestCase
  let(:unit_class) { Coordinates }

  describe "#neighbors" do
    # rubocop:disable Layout/ExtraSpacing
    # rubocop:disable Layout/MultilineArrayLineBreaks
    # rubocop:disable Style/TrailingCommaInArrayLiteral
    context "GIVEN an upper-left Coordinates" do
      subject { unit_class[0, 0] }

      it "returns the expected Array" do
        _(subject.neighbors).must_equal([
          unit_class[-1, -1], unit_class[0, -1], unit_class[1, -1],
          unit_class[-1,  0],                    unit_class[1,  0],
          unit_class[-1,  1], unit_class[0,  1], unit_class[1,  1],
        ])
      end
    end

    context "GIVEN a middle Coordinates" do
      subject { unit_class[1, 1] }

      it "returns the expected Array" do
        _(subject.neighbors).must_equal([
          unit_class[0, 0], unit_class[1, 0], unit_class[2, 0],
          unit_class[0, 1],                   unit_class[2, 1],
          unit_class[0, 2], unit_class[1, 2], unit_class[2, 2],
        ])
      end
    end

    context "GIVEN a lower-right Coordinates" do
      subject { unit_class[2, 2] }

      it "returns the expected Array" do
        _(subject.neighbors).must_equal([
          unit_class[1, 1], unit_class[2, 1], unit_class[3, 1],
          unit_class[1, 2],                   unit_class[3, 2],
          unit_class[1, 3], unit_class[2, 3], unit_class[3, 3],
        ])
      end
    end
    # rubocop:enable Style/TrailingCommaInArrayLiteral
    # rubocop:enable Layout/MultilineArrayLineBreaks
    # rubocop:enable Layout/ExtraSpacing
  end

  describe "#<=>" do
    let(:coordinates_array1) {
      [unit_class[1, 1], unit_class[0, 2], unit_class[0, 1]]
    }

    it "allows for sorting of Coordinates" do
      _(coordinates_array1.sort).must_equal(
        [unit_class[0, 1], unit_class[1, 1], unit_class[0, 2]])
    end

    context "GIVEN a non-Coordinates comparison object" do
      subject { unit_class[0, 0] }

      it "raises TypeError" do
        exception = _(-> { subject <=> Object.new }).must_raise(TypeError)
        _(exception.message).must_equal(
          "can't compare with non-Coordinates objects, got Object")
      end
    end
  end

  describe "#succ" do
    subject { unit_class[0, 0] }

    it "returns the expected Coordinates" do
      _(subject.succ).must_equal(Coordinates[1, 0])
    end
  end

  describe "#to_a" do
    subject { unit_class[0, 0] }

    it "returns the expected Array" do
      _(subject.to_a).must_equal([0, 0])
    end
  end
end
