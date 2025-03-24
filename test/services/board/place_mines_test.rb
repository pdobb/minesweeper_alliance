# frozen_string_literal: true

require "test_helper"

class Board::PlaceMinesTest < ActiveSupport::TestCase
  let(:unit_class) { Board::PlaceMines }

  let(:win1_board) { boards(:win1_board) }

  let(:standing_by1_board) { boards(:standing_by1_board) }
  let(:standing_by1_board_cell4) { cells(:standing_by1_board_cell4) }
  let(:standing_by1_board_cell9) { cells(:standing_by1_board_cell9) }

  let(:new_board1) { new_game1.build_board(settings: custom_settings1) }
  let(:new_game1) { Game.new }
  let(:custom_settings1) { Board::Settings[4, 4, 1] }

  describe "#call" do
    given "Board#new_record? = true" do
      subject {
        unit_class.new(
          board: new_board1,
          coordinates_array: nil,
          seed_cell: "ANYTHING")
      }

      it "raises Board::PlaceMines::Error" do
        exception =
          _(-> { subject.call }).must_raise(Board::PlaceMines::Error)
        _(exception.message).must_equal(
          "can't place mines in an unsaved Board")
      end
    end

    given "Board#new_record? = false" do
      given "mines have already been placed" do
        subject {
          unit_class.new(
            board: win1_board,
            coordinates_array: nil,
            seed_cell: "ANYTHING")
        }

        it "raises Board::PlaceMines::Error" do
          exception =
            _(-> { subject.call }).must_raise(Board::PlaceMines::Error)
          _(exception.message).must_equal("mines have already been placed")
        end
      end

      given "mines have not yet been placed" do
        subject {
          unit_class.new(
            board: standing_by1_board,
            coordinates_array: coordinates_array1,
            seed_cell: seed_cell1)
        }

        given "no mine/seed_cell collision" do
          let(:seed_cell1) { standing_by1_board_cell4 }

          context "Given an Array of Coordinates" do
            let(:coordinates_array1) {
              [Coordinates[0, 0], Coordinates[2, 2]]
            }

            it "places the expected number of mines" do
              result =
                _(-> { subject.call }).must_change(
                  "standing_by1_board.cells.is_mine.count",
                  from: 0,
                  to: coordinates_array1.size)
              _(result).must_be_same_as(subject)
            end
          end

          given "an actual CoordinatesArray" do
            let(:coordinates_array1) {
              CoordinatesArray.new([Coordinates[0, 0], Coordinates[2, 2]])
            }

            it "places the expected number of mines" do
              result =
                _(-> { subject.call }).must_change(
                  "standing_by1_board.cells.is_mine.count",
                  from: 0,
                  to: coordinates_array1.size)
              _(result).must_be_same_as(subject)
            end
          end
        end

        given "a mine/seed_cell collision" do
          let(:seed_cell1) { standing_by1_board_cell9 }
          let(:coordinates_array1) { [Coordinates[0, 0], Coordinates[2, 2]] }

          it "places one less mine cell" do
            result =
              _(-> { subject.call }).must_change(
                "standing_by1_board.cells.is_mine.count",
                from: 0,
                to: coordinates_array1.size.pred)
            _(result).must_be_same_as(subject)
          end
        end
      end
    end
  end
end
