# frozen_string_literal: true

require "test_helper"

class CoordinatesTestType < ActiveSupport::TestCase
  describe "CoordinatesType" do
    let(:unit_class) { CoordinatesType }

    subject { CoordinatesType.new }

    describe "#type" do
      it "returns :coordinates" do
        _(subject.type).must_equal(:coordinates)
      end
    end

    describe "#cast" do
      context "GIVEN a Coordinates" do
        it "returns the expected value" do
          result = subject.cast(Coordinates[9, 9])
          _(result).must_equal(Coordinates[9, 9])
        end
      end

      context "GIVEN a Hash" do
        it "returns the expected value" do
          result = subject.cast({ x: 9, y: 9 })
          _(result).must_equal(Coordinates[9, 9])
        end
      end

      context "GIVEN a validly formatted String" do
        it "returns the expected value" do
          result =
            subject.cast(ActiveSupport::JSON.encode({ x: 9, y: 9 }))
          _(result).must_equal(Coordinates[9, 9])
        end
      end

      context "GIVEN an invalidly formatted String" do
        it "returns the expected value" do
          result = subject.cast("INVALID")
          _(result).must_be_instance_of(NullCoordinates)
        end
      end

      context "GIVEN an unexpected type" do
        it "returns NullCoordinates" do
          result = subject.cast(Object.new)
          _(result).must_be_instance_of(NullCoordinates)
        end
      end
    end

    describe "#serialize" do
      context "GIVEN a Coordinates" do
        it "returns the Coordinates, formatted as JSON" do
          result = subject.serialize(Coordinates[9, 9])
          _(result).must_equal(ActiveSupport::JSON.encode({ x: 9, y: 9 }))
        end
      end

      context "GIVEN a Hash" do
        it "returns the Hash, formatted as JSON" do
          result = subject.serialize({ x: 9, y: 9 })
          _(result).must_equal(ActiveSupport::JSON.encode({ x: 9, y: 9 }))
        end
      end

      context "GIVEN a String" do
        it "returns the String, formatted as JSON" do
          result = subject.serialize("TEST")
          _(result).must_equal(ActiveSupport::JSON.encode("TEST"))
        end
      end

      context "GIVEN nil" do
        it "returns an empty JSON object" do
          result = subject.serialize(nil)
          _(result).must_equal("{}")
        end
      end

      context "GIVEN an unknown type" do
        it "returns a serialized NullCoordinates object" do
          result = subject.serialize(Object.new)
          _(result).must_equal(ActiveSupport::JSON.encode(NullCoordinates.new))
        end
      end
    end
  end
end
