# frozen_string_literal: true

require "test_helper"

class EngagementTallyTest < ActiveSupport::TestCase
  describe "EngagementTally" do
    context "GIVEN no arguments" do
      subject { EngagementTally.new }

      describe "#to_h" do
        it "returns the expected Hash" do
          value(subject.to_h).must_equal({ wins: 1, losses: 1 })
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          value(subject.to_s).must_equal("Alliance: 1 / Mines: 1")
        end
      end

      describe "#wins_count" do
        it "returns the expected Integer" do
          value(subject.wins_count).must_equal(1)
        end
      end

      describe "#losses_count" do
        it "returns the expected Integer" do
          value(subject.losses_count).must_equal(1)
        end
      end
    end

    context "GIVEN a narrow `between` Time range argument" do
      subject { EngagementTally.new(2.minutes.ago..) }

      describe "#to_h" do
        it "returns the expected Hash" do
          value(subject.to_h).must_equal({ wins: 0, losses: 1 })
        end
      end

      describe "#to_s" do
        it "returns the expected String" do
          value(subject.to_s).must_equal("Alliance: 0 / Mines: 1")
        end
      end

      describe "#wins_count" do
        it "returns the expected Integer" do
          value(subject.wins_count).must_equal(0)
        end
      end

      describe "#losses_count" do
        it "returns the expected Integer" do
          value(subject.losses_count).must_equal(1)
        end
      end
    end
  end
end
