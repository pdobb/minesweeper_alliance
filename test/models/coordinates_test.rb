# frozen_string_literal: true

require "test_helper"

class CoordinatesTest < ActiveSupport::TestCase
  describe "Coordinates" do
    let(:unit_class) { Coordinates }

    # rubocop:disable Layout/ExtraSpacing
    # rubocop:disable Layout/MultilineArrayLineBreaks
    # rubocop:disable Style/TrailingCommaInArrayLiteral
    context "GIVEN an upper-left Coordinates" do
      subject { unit_class[0, 0] }

      describe "#neighbors" do
        it "returns the expected Array" do
          value(subject.neighbors).must_equal([
            unit_class[-1, -1], unit_class[0, -1], unit_class[1, -1],
            unit_class[-1,  0],                    unit_class[1,  0],
            unit_class[-1,  1], unit_class[0,  1], unit_class[1,  1],
          ])
        end
      end
    end

    context "GIVEN a middle Coordinates" do
      subject { unit_class[1, 1] }

      describe "#neighbors" do
        it "returns the expected Array" do
          value(subject.neighbors).must_equal([
            unit_class[0, 0], unit_class[1, 0], unit_class[2, 0],
            unit_class[0, 1],                   unit_class[2, 1],
            unit_class[0, 2], unit_class[1, 2], unit_class[2, 2],
          ])
        end
      end
    end

    context "GIVEN a lower-right Coordinates" do
      subject { unit_class[2, 2] }

      describe "#neighbors" do
        it "returns the expected Array" do
          value(subject.neighbors).must_equal([
            unit_class[1, 1], unit_class[2, 1], unit_class[3, 1],
            unit_class[1, 2],                   unit_class[3, 2],
            unit_class[1, 3], unit_class[2, 3], unit_class[3, 3],
          ])
        end
      end
    end
    # rubocop:enable Style/TrailingCommaInArrayLiteral
    # rubocop:enable Layout/MultilineArrayLineBreaks
    # rubocop:enable Layout/ExtraSpacing
  end
end
