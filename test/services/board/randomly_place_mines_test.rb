# frozen_string_literal: true

require "test_helper"

class Board::RandomlyPlaceMinesTest < ActiveSupport::TestCase
  let(:win1_board) { boards(:win1_board) }
  let(:standing_by1_board) { boards(:standing_by1_board) }
  let(:new_board1) { new_game1.build_board(settings: custom_settings1) }
  let(:new_game1) { Game.new }
  let(:custom_settings1) { Board::Settings[4, 4, 1] }
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }

  describe "#call" do
    given "Board#new_record? = true" do
      subject {
        Board::RandomlyPlaceMines.new(board: new_board1, seed_cell: nil)
      }

      it "raises Board::RandomlyPlaceMines::Error" do
        exception =
          _(-> { subject.call }).must_raise(Board::RandomlyPlaceMines::Error)
        _(exception.message).must_equal(
          "can't place mines in an unsaved Board")
      end
    end

    given "Board#new_record? = false" do
      given "mines have already been placed" do
        subject {
          Board::RandomlyPlaceMines.new(board: win1_board, seed_cell: nil)
        }

        it "raises Board::RandomlyPlaceMines::Error" do
          exception =
            _(-> { subject.call }).must_raise(
              Board::RandomlyPlaceMines::Error)
          _(exception.message).must_equal("mines have already been placed")
        end
      end

      given "mines have not yet been placed" do
        subject {
          Board::RandomlyPlaceMines.new(
            board: standing_by1_board,
            seed_cell: standing_by1_board_cell1)
        }

        it "places the expected number of mines and returns the Board" do
          result =
            _(-> { subject.call }).must_change(
              "standing_by1_board.cells.is_mine.count", from: 0, to: 1)

          _(result).must_be_same_as(subject)
        end

        it "doesn't place a mine in the seed Cell" do
          standing_by1_board.cells.excluding(standing_by1_board_cell1)
            .delete_all

          _(standing_by1_board.cells.size).must_equal(1)

          _(-> { subject.call }).wont_change(
            "standing_by1_board.cells.is_mine.count")
        end

        # TODO: I'm not sure how to test for random placement...
      end
    end
  end
end
