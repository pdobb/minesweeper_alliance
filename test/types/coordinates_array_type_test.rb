# frozen_string_literal: true

require "test_helper"

class CoordinatesArrayTypeTest < ActiveSupport::TestCase
  let(:coordinates_array1) { CoordinatesArray.new(coordinates1) }
  let(:coordinates1) { Coordinates[9, 9] }

  describe "#type" do
    subject { CoordinatesArrayType.new }

    it "returns :coordinates" do
      _(subject.type).must_equal(:coordinates_array)
    end
  end

  describe "#cast" do
    subject { CoordinatesArrayType.new }

    given "a CoordinatesArray" do
      it "returns the expected value" do
        result = subject.cast(coordinates_array1)
        _(result).must_equal(coordinates_array1)
      end
    end

    given "a Array" do
      it "returns the expected value" do
        result = subject.cast([coordinates1])
        _(result).must_equal(coordinates_array1)
      end
    end

    given "a validly formatted String" do
      it "returns the expected value" do
        result =
          subject.cast(ActiveSupport::JSON.encode([coordinates1]))
        _(result).must_equal(coordinates_array1)
      end
    end

    given "an invalidly formatted String" do
      it "returns the expected value" do
        result = subject.cast("INVALID")
        _(result).must_equal([])
      end
    end

    given "an unexpected type" do
      it "returns NullCoordinates" do
        result = subject.cast(Object.new)
        _(result).must_equal([])
      end
    end
  end

  describe "#serialize" do
    subject { CoordinatesArrayType.new }

    given "a CoordinatesArray" do
      it "returns the CoordinatesArray, formatted as JSON" do
        result = subject.serialize(coordinates_array1)
        _(result).must_equal(ActiveSupport::JSON.encode([coordinates1]))
      end
    end

    given "nil" do
      it "returns an empty JSON object" do
        result = subject.serialize(nil)
        _(result).must_equal("[]")
      end
    end
  end
end
