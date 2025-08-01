# frozen_string_literal: true

require "test_helper"

class ConversionsTest < ActiveSupport::TestCase
  describe ".Coordinates" do
    subject { Conversions }

    given "a Coordinates instance" do
      let(:instance) { Coordinates[9, 9] }

      it "returns the instance" do
        result = subject.Coordinates(instance)

        _(result).must_be_same_as(instance)
      end
    end

    given "a valid Hash with symbols for keys" do
      it "returns the expected Coordinates" do
        result = subject.Coordinates({ x: 9, y: 9 })

        _(result).must_equal(Coordinates[9, 9])
      end
    end

    given "a valid Hash with strings for keys" do
      it "returns the expected Coordinates" do
        result = subject.Coordinates({ "x" => 9, "y" => 9 })

        _(result).must_equal(Coordinates[9, 9])
      end
    end

    given "a valid Array" do
      it "returns the expected Coordinates" do
        result = subject.Coordinates([9, 9])

        _(result).must_equal(Coordinates[9, 9])
      end
    end

    given "an un-convertible type" do
      it "raises TypeError" do
        exception =
          _(-> { subject.Coordinates("Invalid Type") }).must_raise(TypeError)
        _(exception.message).must_equal(
          "Can't convert unexpected type to Coordinates, got String",
        )
      end
    end
  end
end
