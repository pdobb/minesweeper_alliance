# frozen_string_literal: true

require "test_helper"

class DurationTest < ActiveSupport::TestCase
  let(:unit_class) { Duration }

  describe "#to_s" do
    context "GIVEN a duration of < 1 minute" do
      subject { unit_class.new(9.seconds.ago..) }

      it "returns the expected String" do
        _(subject.to_s).must_equal("9s")
      end
    end

    context "GIVEN a duration of < 1 hour" do
      context "WHERE duration is an even minute" do
        subject { unit_class.new(9.minutes.ago..) }

        it "returns the expected String" do
          _(subject.to_s).must_equal("9m")
        end
      end

      context "WHERE duration is not an even minute" do
        subject { unit_class.new((9.minutes + 9.seconds).ago..) }

        it "returns the expected String" do
          _(subject.to_s).must_equal("9m 9s")
        end
      end
    end

    context "GIVEN a large duration" do
      let(:now) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

      subject {
        unit_class.new(
          (9.years + 9.weeks + 9.hours + 9.minutes + 9.seconds).ago..)
      }

      it "returns the expected String" do
        travel_to(now) do
          _(subject.to_s).must_equal("9y 2m 3d 7h 48m 9s")
        end
      end
    end
  end

  describe "#to_i" do
    subject { unit_class.new(9.seconds.ago..) }

    it "returns the expected Integer" do
      _(subject.to_i).must_equal(9)
    end
  end
end
