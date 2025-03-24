# frozen_string_literal: true

require "test_helper"

class ConversionsTest < ActiveSupport::TestCase
  let(:unit_class) { Conversions }

  describe ".Coordinates" do
    subject { unit_class }

    context "GIVEN a Coordinates instance" do
      let(:instance) { Coordinates[9, 9] }

      it "returns the instance" do
        result = subject.Coordinates(instance)
        _(result).must_be_same_as(instance)
      end
    end

    context "GIVEN a valid Hash with symbols for keys" do
      it "returns the expected Coordinates" do
        result = subject.Coordinates({ x: 9, y: 9 })
        _(result).must_equal(Coordinates[9, 9])
      end
    end

    context "GIVEN a valid Hash with strings for keys" do
      it "returns the expected Coordinates" do
        result = subject.Coordinates({ "x" => 9, "y" => 9 })
        _(result).must_equal(Coordinates[9, 9])
      end
    end

    context "GIVEN a valid Array" do
      it "returns the expected Coordinates" do
        result = subject.Coordinates([9, 9])
        _(result).must_equal(Coordinates[9, 9])
      end
    end

    context "GIVEN an un-convertible type" do
      it "raises TypeError" do
        exception =
          _(-> { subject.Coordinates("Invalid Type") }).must_raise(TypeError)
        _(exception.message).must_equal("Unexpected type, got String")
      end
    end
  end
end
