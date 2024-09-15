# frozen_string_literal: true

require "test_helper"

class Type::BoardSettingsTest < ActiveSupport::TestCase
  describe "Type::BoardSettings" do
    let(:unit_class) { Type::BoardSettings }

    subject { Type::BoardSettings.new }

    describe "#type" do
      it "returns :board_settings" do
        _(subject.type).must_equal(:board_settings)
      end
    end

    describe "#cast" do
      context "GIVEN a Board::Settings" do
        it "returns the expected value" do
          result = subject.cast(Board::Settings[3, 3, 1])
          _(result).must_equal(Board::Settings[3, 3, 1])
        end
      end

      context "GIVEN a Hash" do
        it "returns the expected value" do
          result = subject.cast({ width: 3, height: 3, mines: 1 })
          _(result).must_equal(Board::Settings[3, 3, 1])
        end
      end

      context "GIVEN a validly formatted String" do
        it "returns the expected value" do
          result =
            subject.cast(
              ActiveSupport::JSON.encode({ width: 3, height: 3, mines: 1 }))
          _(result).must_equal(Board::Settings[3, 3, 1])
        end
      end

      context "GIVEN an invalidly formatted String" do
        it "returns the expected value" do
          result = subject.cast("INVALID")
          _(result).must_be_instance_of(Board::NullSettings)
        end
      end

      context "GIVEN an unexpected type" do
        it "returns Board::NullSettings" do
          result = subject.cast(Object.new)
          _(result).must_be_instance_of(Board::NullSettings)
        end
      end
    end

    describe "#serialize" do
      context "GIVEN a Board::Settings" do
        it "returns the Board::Settings, formatted as JSON" do
          result = subject.serialize(Board::Settings[3, 3, 1])
          _(result).must_equal(
            ActiveSupport::JSON.encode({ width: 3, height: 3, mines: 1 }))
        end
      end

      context "GIVEN a Hash" do
        it "returns the Hash, formatted as JSON" do
          result = subject.serialize({ width: 3, height: 3, mines: 1 })
          _(result).must_equal(
            ActiveSupport::JSON.encode({ width: 3, height: 3, mines: 1 }))
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
        it "returns a serialized Board::NullSettings object" do
          result = subject.serialize(Object.new)
          _(result).must_equal(
            ActiveSupport::JSON.encode(Board::NullSettings.new))
        end
      end
    end
  end
end
