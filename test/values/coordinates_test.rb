# frozen_string_literal: true

require "test_helper"

class CoordinatesTest < ActiveSupport::TestCase
  describe "#neighbors" do
    # rubocop:disable Layout/ExtraSpacing
    # rubocop:disable Layout/MultilineArrayLineBreaks
    # rubocop:disable Style/TrailingCommaInArrayLiteral
    given "an upper-left Coordinates" do
      subject { Coordinates[0, 0] }

      it "returns the expected Array" do
        _(subject.neighbors).must_equal(CoordinatesSet.new([
          Coordinates[-1, -1], Coordinates[0, -1], Coordinates[1, -1],
          Coordinates[-1,  0],                     Coordinates[1,  0],
          Coordinates[-1,  1], Coordinates[0,  1], Coordinates[1,  1],
        ]))
      end
    end

    given "a middle Coordinates" do
      subject { Coordinates[1, 1] }

      it "returns the expected Array" do
        _(subject.neighbors).must_equal(CoordinatesSet.new([
          Coordinates[0, 0], Coordinates[1, 0], Coordinates[2, 0],
          Coordinates[0, 1],                    Coordinates[2, 1],
          Coordinates[0, 2], Coordinates[1, 2], Coordinates[2, 2],
        ]))
      end
    end

    given "a lower-right Coordinates" do
      subject { Coordinates[2, 2] }

      it "returns the expected Array" do
        _(subject.neighbors).must_equal(CoordinatesSet.new([
          Coordinates[1, 1], Coordinates[2, 1], Coordinates[3, 1],
          Coordinates[1, 2],                    Coordinates[3, 2],
          Coordinates[1, 3], Coordinates[2, 3], Coordinates[3, 3],
        ]))
      end
    end
    # rubocop:enable Style/TrailingCommaInArrayLiteral
    # rubocop:enable Layout/MultilineArrayLineBreaks
    # rubocop:enable Layout/ExtraSpacing
  end

  describe "#<=>" do
    let(:coordinates_set1) {
      [Coordinates[1, 1], Coordinates[0, 2], Coordinates[0, 1]]
    }

    it "allows for sorting of Coordinates" do
      _(coordinates_set1).must_match_array(
        [Coordinates[0, 1], Coordinates[1, 1], Coordinates[0, 2]],
      )
    end

    given "a non-Coordinates comparison object" do
      subject { Coordinates[0, 0] }

      it "raises TypeError" do
        exception = _(-> { subject <=> Object.new }).must_raise(TypeError)
        _(exception.message).must_equal(
          "Can't convert unexpected type to Coordinates, got Object",
        )
      end
    end
  end

  describe "#succ" do
    subject { Coordinates[0, 0] }

    it "returns the expected Coordinates" do
      _(subject.succ).must_equal(Coordinates[1, 0])
    end
  end

  describe "#to_a" do
    subject { Coordinates[0, 0] }

    it "returns the expected Array" do
      _(subject.to_a).must_equal([0, 0])
    end
  end
end
