# frozen_string_literal: true

require "test_helper"

class Game::StartTest < ActiveSupport::TestCase
  let(:win1) { games(:win1) }
  let(:standing_by1) { games(:standing_by1) }

  let(:user1) { users(:user1) }

  describe ".call" do
    before do
      MuchStub.on_call(Board::RandomlyPlaceMines, :call) { |call|
        @randomly_place_mines_call = call
      }
    end

    subject { Game::Start }

    given "Game#status_standing_by? = true" do
      let(:game1) { standing_by1 }

      it "orchestrates the expected updates and returns the Game" do
        result =
          _(-> {
            subject.call(game: game1, user: user1, seed_cell: nil)
          }).must_change_all([
            ["game1.started_at"],
            [
              "game1.status",
              from: Game.status_standing_by,
              to: Game.status_sweep_in_progress,
            ],
          ])

        _(result).must_be_same_as(game1)
        _(@randomly_place_mines_call.kargs.fetch(:seed_cell)).must_be_nil
      end
    end

    given "Game#status_standing_by? = false" do
      let(:game1) { win1 }

      it "returns the Game without orchestrating any changes" do
        result =
          _(-> {
            subject.call(game: win1, user: user1, seed_cell: nil)
          }).wont_change_all([
            ["game1.started_at"],
            ["game1.status"],
          ])

        _(result).must_be_same_as(game1)
        _(@randomly_place_mines_call).must_be_nil
      end
    end
  end
end
