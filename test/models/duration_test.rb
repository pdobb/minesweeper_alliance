# frozen_string_literal: true

require "test_helper"

class DurationTest < ActiveSupport::TestCase
  describe "Duration" do
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
        subject {
          unit_class.new(
            (9.years + 9.weeks + 9.hours + 9.minutes + 9.seconds).ago..)
        }

        it "returns the expected String" do
          _(subject.to_s).must_equal("9y 2m 3d 7h 48m 9s")
        end
      end
    end
  end
end
