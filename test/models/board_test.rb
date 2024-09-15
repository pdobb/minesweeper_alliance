# frozen_string_literal: true

require "test_helper"

class BoardTest < ActiveSupport::TestCase
  describe "Board" do
    let(:unit_class) { Board }

    let(:win1_board) { boards(:win1_board) }
    let(:loss1_board) { boards(:loss1_board) }
    let(:standing_by1_board) { boards(:standing_by1_board) }
    let(:new_board) {
      unit_class.build_for(
        game: new_game,
        difficulty_level: difficulty_level_test)
    }

    let(:new_game) { Game.new }
    let(:difficulty_level_test) { DifficultyLevel.new("Test") }

    context "Class Methods" do
      subject { unit_class }

      describe ".build_for" do
        it "orchestrates building of the expected object graph and returns "\
           "the new Board" do
          result =
            subject.build_for(
              game: new_game,
              difficulty_level: difficulty_level_test)

          _(result).must_be_instance_of(unit_class)
          _(result.game).must_be_same_as(new_game)
          _(result.cells).must_be_empty
        end
      end
    end

    describe "#cells" do
      subject { [new_board, win1_board].sample }

      it "sorts the association by least recent" do
        result = subject.cells.to_sql
        _(result).must_include(%(ORDER BY "cells"."created_at" ASC))
      end
    end

    describe "#place_mines" do
      context "GIVEN a new Board" do
        subject { new_board }

        it "raises Board::Error" do
          exception =
            _(-> {
              subject.place_mines
            }).must_raise(Board::Error)
          _(exception.message).must_equal(
            "mines can't be placed on an unsaved Board")
        end
      end

      context "GIVEN mines have already been placed" do
        subject { win1_board }

        it "raises Board::Error" do
          exception =
            _(-> {
              subject.place_mines
            }).must_raise(Board::Error)
          _(exception.message).must_equal("mines have already been placed")
        end
      end

      context "GIVEN mines have not yet been placed" do
        subject { standing_by1_board }

        let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }

        it "places the expected number of mines and returns the Board" do
          result =
            _(-> {
              subject.place_mines(seed_cell: standing_by1_board_cell1)
            }).must_change("subject.mines_count", from: 0, to: 1)
          _(result).must_be_same_as(subject)
        end

        it "doesn't place the a mine in the seed Cell" do
          subject.cells.excluding(standing_by1_board_cell1).delete_all
          _(subject.cells.size).must_equal(1)

          _(-> {
            subject.place_mines(seed_cell: standing_by1_board_cell1)
          }).wont_change("subject.mines_count")
        end

        # TODO: I'm not sure how to test for random placement...
      end
    end

    describe "#check_for_victory" do
      before do
        MuchStub.on_call(subject.game, :end_in_victory) { |call|
          @end_in_victory_call = call
        }
      end

      context "GIVEN the associated Game#status_in_progress? = false" do
        subject { [standing_by1_board, win1_board, loss1_board].sample }

        it "returns the Game without orchestrating any changes" do
          result = subject.check_for_victory
          _(result).must_be_same_as(subject)
          _(@end_in_victory_call).must_be_nil
        end
      end

      context "GIVEN the associated Game#status_in_progress? = true" do
        context "GIVEN the Board is not yet in a victorious state" do
          before do
            subject.game.start(seed_cell: nil)
          end

          subject { standing_by1_board }

          it "doesn't call Game#end_in_vicotry, and returns the Board" do
            result = subject.check_for_victory
            _(@end_in_victory_call).must_be_nil
            _(result).must_be_same_as(subject)
          end
        end

        context "GIVEN the Board is in a victorious state" do
          before do
            subject.game.start(seed_cell: nil)
            subject.cells.is_not_mine.update_all(revealed: true)
          end

          subject { standing_by1_board }

          it "calls Game#end_in_vicotry, and returns the Board" do
            result = subject.check_for_victory
            _(@end_in_victory_call).wont_be_nil
            _(result).must_be_same_as(subject)
          end
        end
      end
    end

    describe "#mines_count" do
      subject { win1_board }

      it "returns the expected Integer" do
        _(subject.mines_count).must_equal(1)
      end
    end

    describe "#flags_count" do
      subject { win1_board }

      it "returns the expected Integer" do
        _(subject.flags_count).must_equal(1)
      end
    end

    describe "#grid" do
      before do
        MuchStub.on_call(Grid, :build_for) { |call| @build_for_call = call }
      end

      subject { standing_by1_board }

      it "forwards to Grid.build_for" do
        subject.grid
        _(@build_for_call).wont_be_nil
        _(@build_for_call.pargs).wont_be_empty
        _(@build_for_call.kargs).must_equal({ context: nil })
      end
    end

    describe "#clamp_coordinates" do
      let(:coordinates_array) {
        # rubocop:disable all
        [
          Coordinates[-1, -1], Coordinates[-1,  0], Coordinates[0, -1],
          *valid_coordiantes,
          Coordinates[ 0,  3], Coordinates[ 3,  0], Coordinates[3,  3],
        ]
        # rubocop:disable all
      }
      let(:valid_coordiantes) {
        [Coordinates[0, 0], Coordinates[1, 1], Coordinates[2, 2]]
      }

      subject { new_board }

      it "returns an Array that includes Coordinates inside of the Board, "\
         "while excluding Coordinates outside of the Board" do
        result = subject.clamp_coordinates(coordinates_array)
        _(result).must_match_array(valid_coordiantes)
      end
    end

    describe "Settings" do
      let(:unit_class) { Board::Settings }

      context "Class Methods" do
        subject { unit_class }

        describe ".build_for" do
          it "returns the expected object" do
            result =
              subject.build_for(difficulty_level: DifficultyLevel.new("Test"))
            _(result).must_equal(subject[3, 3, 1])
          end
        end
      end
    end

    describe "Generate" do
      let(:unit_class) { Board::Generate }

      describe "#call" do
        before do
          standing_by1_board.cells.delete_all

          MuchStub.on_call(Cell, :insert_all!) { |call|
            @insert_all_call = call
          }
        end

        let(:board_id) { standing_by1_board.id }
        let(:now) { Time.current.at_beginning_of_minute }
        def build_timestamp_for(index)
          now + (index * Rational("0.00001"))
        end

        subject { unit_class.new(standing_by1_board) }

        it "builds/inserts the expected cell data Hashes" do
          travel_to(now) do
            subject.call

            cell_data = @insert_all_call.pargs.first
            _(cell_data).must_equal([
              {
                board_id: board_id,
                coordinates: Coordinates[0, 0],
                created_at: build_timestamp_for(0),
                updated_at: build_timestamp_for(0),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[1, 0],
                created_at: build_timestamp_for(1),
                updated_at: build_timestamp_for(1),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[2, 0],
                created_at: build_timestamp_for(2),
                updated_at: build_timestamp_for(2),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[0, 1],
                created_at: build_timestamp_for(3),
                updated_at: build_timestamp_for(3),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[1, 1],
                created_at: build_timestamp_for(4),
                updated_at: build_timestamp_for(4),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[2, 1],
                created_at: build_timestamp_for(5),
                updated_at: build_timestamp_for(5),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[0, 2],
                created_at: build_timestamp_for(6),
                updated_at: build_timestamp_for(6),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[1, 2],
                created_at: build_timestamp_for(7),
                updated_at: build_timestamp_for(7),
              },
              {
                board_id: board_id,
                coordinates: Coordinates[2, 2],
                created_at: build_timestamp_for(8),
                updated_at: build_timestamp_for(8),
              },
            ])
          end
        end
      end
    end
  end
end
