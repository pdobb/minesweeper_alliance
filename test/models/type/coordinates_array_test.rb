# frozen_string_literal: true

require "test_helper"

class Type::CoordinatesArrayTest < ActiveSupport::TestCase
  describe "Type::CoordinatesArray" do
    let(:unit_class) { Type::CoordinatesArray }

    let(:coordinates_array1) { CoordinatesArray.new(coordinates1) }
    let(:coordinates1) { Coordinates[9, 9] }

    subject { Type::CoordinatesArray.new }

    describe "#type" do
      it "returns :coordinates" do
        _(subject.type).must_equal(:coordinates_array)
      end
    end

    describe "#cast" do
      context "GIVEN a CoordinatesArray" do
        it "returns the expected value" do
          result = subject.cast(coordinates_array1)
          _(result).must_equal(coordinates_array1)
        end
      end

      context "GIVEN a Array" do
        it "returns the expected value" do
          result = subject.cast([coordinates1])
          _(result).must_equal(coordinates_array1)
        end
      end

      context "GIVEN a validly formatted String" do
        it "returns the expected value" do
          result =
            subject.cast(ActiveSupport::JSON.encode([coordinates1]))
          _(result).must_equal(coordinates_array1)
        end
      end

      context "GIVEN an invalidly formatted String" do
        it "returns the expected value" do
          result = subject.cast("INVALID")
          _(result).must_equal([])
        end
      end

      context "GIVEN an unexpected type" do
        it "returns NullCoordinates" do
          result = subject.cast(Object.new)
          _(result).must_equal([])
        end
      end
    end

    describe "#serialize" do
      context "GIVEN a CoordinatesArray" do
        it "returns the CoordinatesArray, formatted as JSON" do
          result = subject.serialize(coordinates_array1)
          _(result).must_equal(ActiveSupport::JSON.encode([coordinates1]))
        end
      end

      context "GIVEN nil" do
        it "returns an empty JSON object" do
          result = subject.serialize(nil)
          _(result).must_equal("[]")
        end
      end
    end
  end
end