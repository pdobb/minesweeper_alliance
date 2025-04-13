# frozen_string_literal: true

require "test_helper"

class Board::CheckForVictoryTest < ActiveSupport::TestCase
  let(:win1_board) { boards(:win1_board) }
  let(:loss1_board) { boards(:loss1_board) }
  let(:standing_by1_board) { boards(:standing_by1_board) }

  let(:user1) { users(:user1) }

  describe ".call" do
    before do
      MuchStub.tap_on_call(Game::EndInVictory, :call) { |call|
        @game_end_in_victory_call = call
      }
    end

    subject { Board::CheckForVictory }

    given "the associated Game#status_sweep_in_progress? == false" do
      let(:board1) { [standing_by1_board, win1_board, loss1_board].sample }

      it "doesn't orchestrate any changes, and returns nil" do
        result = subject.call(board: board1, user: user1)
        _(result).must_be_nil
        _(@game_end_in_victory_call).must_be_nil
      end
    end

    given "the associated Game#status_sweep_in_progress? == true" do
      given "the Board is not yet in a victorious state" do
        before do
          Game::Start.(game: board1.game, user: user1, seed_cell: nil)
        end

        let(:board1) { standing_by1_board }

        it "doesn't call Game::EndInVictory, and returns false" do
          result = subject.call(board: board1, user: user1)
          _(result).must_equal(false)
          _(@game_end_in_victory_call).must_be_nil
        end
      end

      given "the Board is in a victorious state" do
        before do
          Game::Start.(game: board1.game, user: user1, seed_cell: nil)
          board1.cells.is_not_mine.update_all(revealed: true)
          board1.cells.reload
        end

        let(:board1) { standing_by1_board }

        it "calls Game::EndInVictory, and returns the Game" do
          result = subject.call(board: board1, user: user1)
          _(result).must_be_same_as(board1.game)
          _(@game_end_in_victory_call).wont_be_nil
        end
      end
    end
  end
end
