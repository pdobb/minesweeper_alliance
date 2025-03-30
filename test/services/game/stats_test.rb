# frozen_string_literal: true

require "test_helper"

class Game::StatsTest < ActiveSupport::TestCase
  let(:unit_class) { Game::Stats }

  let(:win1) { games(:win1) }
  let(:standing_by1) { games(:standing_by1) }

  let(:user1) { users(:user1) }

  describe ".duration" do
    subject { unit_class }

    given "Game#on?" do
      before { standing_by1.start(seed_cell: nil, user: user1) }

      it "returns nil" do
        _(subject.duration(standing_by1)).must_be_nil
      end
    end

    given "Game#over?" do
      it "returns the expected Time range" do
        _(subject.duration(win1)).must_equal(30.0)
      end
    end
  end

  describe "#engagement_time_range" do
    subject { unit_class }

    given "Game#on?" do
      it "returns the expected Time Range" do
        _(subject.engagement_time_range(standing_by1)).must_equal(
          standing_by1.started_at..)
      end
    end

    given "Game#over?" do
      it "returns the expected Time Range" do
        _(subject.engagement_time_range(win1)).must_equal(
          win1.started_at..win1.ended_at)
      end
    end
  end
end
