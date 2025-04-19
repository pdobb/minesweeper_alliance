# frozen_string_literal: true

require "test_helper"

class CoordinatesSetTypeTest < ActiveSupport::TestCase
  let(:coordinates_set1) { CoordinatesSet.new(coordinates1) }
  let(:coordinates1) { Coordinates[9, 9] }

  describe "#type" do
    subject { CoordinatesSetType.new }

    it "returns :coordinates_set" do
      _(subject.type).must_equal(:coordinates_set)
    end
  end

  describe "#cast" do
    subject { CoordinatesSetType.new }

    given "a CoordinatesSet" do
      it "returns the expected CoordinatesSet" do
        result = subject.cast(coordinates_set1)
        _(result).must_equal(coordinates_set1)
      end
    end

    given "an Array" do
      it "returns the expected CoordinatesSet" do
        result = subject.cast([coordinates1])
        _(result).must_equal(coordinates_set1)
      end
    end

    given "a validly formatted String" do
      it "returns the expected CoordinatesSet" do
        result =
          subject.cast(ActiveSupport::JSON.encode([coordinates1]))
        _(result).must_equal(coordinates_set1)
      end
    end

    given "an invalidly formatted String" do
      it "returns an empty Array" do
        result = subject.cast("INVALID")
        _(result).must_equal([])
      end
    end

    given "an unexpected type" do
      it "returns an empty Array" do
        result = subject.cast(Object.new)
        _(result).must_equal([])
      end
    end
  end

  describe "#serialize" do
    subject { CoordinatesSetType.new }

    given "a CoordinatesSet" do
      it "returns the CoordinatesSet, formatted as JSON" do
        result = subject.serialize(coordinates_set1)
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
