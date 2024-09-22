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
        difficulty_level: custom_difficulty_level1)
    }

    let(:new_game) { Game.new }
    let(:custom_difficulty_level1) {
      CustomDifficultyLevel.new(width: 3, height: 3, mines: 1)
    }

    context "Class Methods" do
      subject { unit_class }

      describe ".build_for" do
        it "orchestrates building of the expected object graph and returns "\
           "the new Board" do
          result =
            subject.build_for(
              game: new_game,
              difficulty_level: custom_difficulty_level1)

          _(result).must_be_instance_of(unit_class)
          _(result.game).must_be_same_as(new_game)
          _(result.cells).must_be_empty
        end
      end
    end

    describe "#validate" do
      describe "#settings" do
        subject {
          unit_class.build_for(
            game: new_game,
            difficulty_level:
              CustomDifficultyLevel.new(
                width: width1, height: height1, mines: mines1))
        }
        let(:width1) { 3 }
        let(:height1) { 3 }
        let(:mines1) { 1 }

        context "GIVEN a valid #width value" do
          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_be_empty
          end
        end

        context "GIVEN an out-of-range #width value" do
          let(:width1) { [2, 31].sample }

          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_include(
              "width #{ValidationError.in(3..30)}")
          end
        end

        context "GIVEN a valid #height value" do
          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_be_empty
          end
        end

        context "GIVEN an out-of-range #height value" do
          let(:height1) { [2, 31].sample }

          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_include(
              "height #{ValidationError.in(3..30)}")
          end
        end

        context "GIVEN a valid #mines value" do
          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_be_empty
          end
        end

        context "GIVEN an out-of-range #mines value" do
          let(:mines1) { [0, 226].sample }

          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_include(
              "mines #{ValidationError.in(1..225)}")
          end
        end

        context "GIVEN a valid #mines value" do
          let(:mines1) { [1, 8].sample }

          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_be_empty
          end
        end

        context "GIVEN too many #mines" do
          let(:mines1) { 10 }

          it "passes validation" do
            subject.validate
            _(subject.errors[:settings]).must_include("can't be > total cells")
          end
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
            }).must_change("subject.cells.is_mine.count", from: 0, to: 1)
          _(result).must_be_same_as(subject)
        end

        it "doesn't place a mine in the seed Cell" do
          subject.cells.excluding(standing_by1_board_cell1).delete_all
          _(subject.cells.size).must_equal(1)

          _(-> {
            subject.place_mines(seed_cell: standing_by1_board_cell1)
          }).wont_change("subject.cells.is_mine.count")
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

    describe "#cells_at" do
      let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
      let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }

      subject { standing_by1_board }

      context "GIVEN a Coordinates" do
        it "returns the expected Array" do
          _(subject.cells_at(Coordinates[0, 0])).must_equal([
            standing_by1_board_cell1,
          ])
        end
      end

      context "GIVEN an Array of Coordinates" do
        it "returns the expected Array" do
          _(subject.cells_at([Coordinates[0, 0], Coordinates[1, 0]])).
            must_equal([standing_by1_board_cell1, standing_by1_board_cell2])
        end
      end
    end

    describe "#any_mines?" do
      context "GIVEN mines present" do
        subject { win1_board }

        it "returns true" do
          _(subject.any_mines?).must_equal(true)
        end
      end

      context "GIVEN no mines present" do
        subject { standing_by1_board }

        it "returns false" do
          _(subject.any_mines?).must_equal(false)
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
        MuchStub.on_call(Grid, :new) { |call| @grid_new_call = call }
      end

      subject { standing_by1_board }

      it "forwards to Grid.new" do
        subject.grid
        _(@grid_new_call).wont_be_nil
        _(@grid_new_call.pargs).wont_be_empty
        _(@grid_new_call.kargs).must_equal({ context: nil })
      end
    end

    describe "#width" do
      subject { standing_by1_board }

      it "returns the expected Array" do
        _(subject.width).must_equal(3)
      end
    end

    describe "#height" do
      subject { standing_by1_board }

      it "returns the expected Array" do
        _(subject.height).must_equal(3)
      end
    end

    describe "#mines" do
      subject { standing_by1_board }

      it "returns the expected Array" do
        _(subject.mines).must_equal(1)
      end
    end

    describe "#dimensions" do
      subject { standing_by1_board }

      it "returns the expected Array" do
        _(subject.dimensions).must_equal("3x3")
      end
    end

    describe "Settings" do
      let(:unit_class) { Board::Settings }

      context "Class Methods" do
        subject { unit_class }

        describe ".build_for" do
          it "returns the expected object" do
            result =
              subject.build_for(
                difficulty_level: DifficultyLevel.new("Beginner"))
            _(result).must_equal(subject[9, 9, 10])
          end
        end
      end

      describe "#to_a" do
        subject {
          unit_class.build_for(
            difficulty_level: DifficultyLevel.new("Beginner"))
        }

        it "returns the expected Array" do
          _(subject.to_a).must_equal([9, 9, 10])
        end
      end

      describe "#area" do
        subject {
          unit_class.build_for(
            difficulty_level: DifficultyLevel.new("Beginner"))
        }

        it "returns the expected Integer" do
          _(subject.area).must_equal(81)
        end
      end

      describe "#dimensions" do
        subject {
          unit_class.build_for(
            difficulty_level: DifficultyLevel.new("Beginner"))
        }

        it "returns the expected Integer" do
          _(subject.dimensions).must_equal("9x9")
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
                board_id:,
                coordinates: Coordinates[0, 0],
                created_at: build_timestamp_for(0),
                updated_at: build_timestamp_for(0),
              },
              {
                board_id:,
                coordinates: Coordinates[1, 0],
                created_at: build_timestamp_for(1),
                updated_at: build_timestamp_for(1),
              },
              {
                board_id:,
                coordinates: Coordinates[2, 0],
                created_at: build_timestamp_for(2),
                updated_at: build_timestamp_for(2),
              },
              {
                board_id:,
                coordinates: Coordinates[0, 1],
                created_at: build_timestamp_for(3),
                updated_at: build_timestamp_for(3),
              },
              {
                board_id:,
                coordinates: Coordinates[1, 1],
                created_at: build_timestamp_for(4),
                updated_at: build_timestamp_for(4),
              },
              {
                board_id:,
                coordinates: Coordinates[2, 1],
                created_at: build_timestamp_for(5),
                updated_at: build_timestamp_for(5),
              },
              {
                board_id:,
                coordinates: Coordinates[0, 2],
                created_at: build_timestamp_for(6),
                updated_at: build_timestamp_for(6),
              },
              {
                board_id:,
                coordinates: Coordinates[1, 2],
                created_at: build_timestamp_for(7),
                updated_at: build_timestamp_for(7),
              },
              {
                board_id:,
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
