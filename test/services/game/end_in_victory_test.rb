# frozen_string_literal: true

require "test_helper"

class Game::EndInVictoryTest < ActiveSupport::TestCase
  let(:win1) { games(:win1) }
  let(:standing_by1) { games(:standing_by1) }

  let(:user1) { users(:user1) }

  describe ".call" do
    subject { Game::EndInVictory }

    given "a Game that's still on" do
      let(:game1) {
        Game::Start.(game: standing_by1, user: user1, seed_cell: nil)
      }

      it "updates Game#ended_at" do
        _(-> { subject.call(game: game1, user: user1) }).must_change(
          "game1.ended_at",
          from: nil,
        )
      end

      it "sets the expected Status" do
        _(-> { subject.call(game: game1, user: user1) }).must_change(
          "game1.status",
          to: Game.status_alliance_wins,
        )
      end

      it "sets Game stats" do
        _(-> { subject.call(game: game1, user: user1) }).must_change_all([
          ["game1.score", { from: nil }],
          ["game1.bbbv", { from: nil }],
          ["game1.bbbvps", { from: nil }],
          ["game1.efficiency", { from: nil }],
        ])
      end
    end

    given "a Game that's already over" do
      before do
        MuchStub.on_call(game1, :touch) { |call| @touch_call = call }
      end

      let(:game1) { win1 }

      it "returns the Game without orchestrating any changes" do
        result = subject.call(game: game1, user: user1)

        _(result).must_be_same_as(game1)
        _(@touch_call).must_be_nil
      end
    end
  end
end
