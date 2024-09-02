# frozen_string_literal: true

require "test_helper"

class EngagementTallyTest < ActiveSupport::TestCase
  describe "EngagementTally" do
    context "GIVEN no arguments" do
      subject { EngagementTally.new }

      describe "#start_time" do
        context "GIVEN no Time range" do
          subject { EngagementTally.new }

          let(:now) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

          it "returns the Time at today, beginning of day" do
            travel_to(now) do
              value(subject.start_time).must_equal(now.at_beginning_of_day)
            end
          end
        end

        context "GIVEN a Time range" do
          subject { EngagementTally.new(start_time..) }

          let(:start_time) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

          it "returns the beginning of the given Time range" do
            travel_to(start_time) do
              value(subject.start_time).must_equal(start_time)
            end
          end
        end
      end

      describe "#end_time" do
        context "GIVEN no Time range" do
          subject { EngagementTally.new }

          let(:now) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

          it "returns the current Time" do
            travel_to(now) do
              value(subject.end_time).must_equal(now)
            end
          end
        end

        context "GIVEN a Time range" do
          subject { EngagementTally.new(..end_time) }

          let(:end_time) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

          it "returns the end of the given Time range" do
            travel_to(end_time) do
              value(subject.end_time).must_equal(end_time)
            end
          end
        end
      end

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

      describe "#alliance_leads?" do
        it "returns the expected Boolean" do
          value(subject.alliance_leads?).must_equal(true)
        end
      end
    end

    context "GIVEN a narrow `between` Time range argument" do
      subject { EngagementTally.new(10.minutes.ago..) }

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

      describe "#alliance_leads?" do
        it "returns the expected Boolean" do
          value(subject.alliance_leads?).must_equal(false)
        end
      end
    end
  end
end
