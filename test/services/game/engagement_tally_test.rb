# frozen_string_literal: true

require "test_helper"

class Game::EngagementTallyTest < ActiveSupport::TestCase
  given "no arguments" do
    subject { Game::EngagementTally.new }

    describe "#start_time" do
      given "no Time range" do
        subject { Game::EngagementTally.new }

        let(:now) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

        it "returns the Time at today, beginning of day" do
          travel_to(now) do
            _(subject.start_time).must_equal(now.at_beginning_of_day)
          end
        end
      end

      given "a Time range" do
        let(:start_time) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

        subject { Game::EngagementTally.new(start_time..) }

        it "returns the beginning of the given Time range" do
          travel_to(start_time) do
            _(subject.start_time).must_equal(start_time)
          end
        end
      end
    end

    describe "#end_time" do
      given "no Time range" do
        subject { Game::EngagementTally.new }

        let(:now) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

        it "returns the current Time" do
          travel_to(now) do
            _(subject.end_time).must_equal(now)
          end
        end
      end

      given "a Time range" do
        let(:end_time) { Time.zone.local(2024, 9, 1, 12, 0, 0) }

        subject { Game::EngagementTally.new(..end_time) }

        it "returns the end of the given Time range" do
          travel_to(end_time) do
            _(subject.end_time).must_equal(end_time)
          end
        end
      end
    end

    describe "#to_h" do
      it "returns the expected Hash" do
        _(subject.to_h).must_equal({ wins: 1, losses: 1 })
      end
    end

    describe "#to_s" do
      it "returns the expected String" do
        _(subject.to_s).must_equal("Alliance: 1 / Mines: 1")
      end
    end

    describe "#wins_count" do
      it "returns the expected Integer" do
        _(subject.wins_count).must_equal(1)
      end
    end

    describe "#losses_count" do
      it "returns the expected Integer" do
        _(subject.losses_count).must_equal(1)
      end
    end

    describe "#alliance_leads?" do
      it "returns the expected Boolean" do
        _(subject.alliance_leads?).must_equal(false)
      end
    end

    describe "#mines_lead?" do
      it "returns the expected Boolean" do
        _(subject.mines_lead?).must_equal(false)
      end
    end
  end

  given "a narrow `between` Time range argument" do
    subject { Game::EngagementTally.new(15.seconds.ago..) }

    describe "#to_h" do
      it "returns the expected Hash" do
        _(subject.to_h).must_equal({ wins: 0, losses: 1 })
      end
    end

    describe "#to_s" do
      it "returns the expected String" do
        _(subject.to_s).must_equal("Alliance: 0 / Mines: 1")
      end
    end

    describe "#wins_count" do
      it "returns the expected Integer" do
        _(subject.wins_count).must_equal(0)
      end
    end

    describe "#losses_count" do
      it "returns the expected Integer" do
        _(subject.losses_count).must_equal(1)
      end
    end

    describe "#alliance_leads?" do
      it "returns the expected Boolean" do
        _(subject.alliance_leads?).must_equal(false)
      end
    end
  end
end
