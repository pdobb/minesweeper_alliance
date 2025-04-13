# frozen_string_literal: true

require "test_helper"

class BoardTest < ActiveSupport::TestCase
  let(:win1_board) { boards(:win1_board) }
  let(:loss1_board) { boards(:loss1_board) }
  let(:standing_by1_board) { boards(:standing_by1_board) }
  let(:new_board1) { new_game1.build_board(settings: custom_settings1) }

  let(:new_game1) { Game.new }
  let(:preset_settings1) { Board::Settings.beginner }
  let(:custom_settings1) { Board::Settings[4, 4, 1] }

  let(:win1_board_cell1) { cells(:win1_board_cell1) }

  let(:user1) { users(:user1) }

  describe ".new" do
    subject { Board }

    it "returns the expected Board" do
      result = subject.new(settings: preset_settings1)
      _(result).must_be_instance_of(Board)
    end
  end

  describe "#validate" do
    describe "#settings" do
      subject {
        new_game1.build_board(
          settings: Board::Settings[width1, height1, mines1])
      }
      let(:width1) { 6 }
      let(:height1) { 6 }
      let(:mines1) { 4 }

      given "a valid #width value" do
        it "passes validation" do
          subject.validate
          _(subject.errors[:mines]).must_be_empty
        end
      end

      given "an out-of-range #width value" do
        let(:width1) { [5, 31].sample }

        it "fails validation" do
          subject.validate
          _(subject.errors[:width]).must_include(
            ValidationError.in(6..30))
        end
      end

      given "a valid #height value" do
        it "passes validation" do
          subject.validate
          _(subject.errors[:mines]).must_be_empty
        end
      end

      given "an out-of-range #height value" do
        let(:height1) { [5, 31].sample }

        it "fails validation" do
          subject.validate
          _(subject.errors[:height]).must_include(
            ValidationError.in(6..30))
        end
      end

      given "a valid #mines value" do
        it "passes validation" do
          subject.validate
          _(subject.errors[:mines]).must_be_empty
        end
      end

      given "an out-of-range #mines value" do
        let(:mines1) { [3, 300].sample }

        it "fails validation" do
          subject.validate
          _(subject.errors[:mines]).must_include(
            ValidationError.in(4..299))
        end
      end

      given "a valid #mines value" do
        let(:mines1) { [4, 12].sample }

        it "passes validation" do
          subject.validate
          _(subject.errors[:mines]).must_be_empty
        end
      end

      given "too many #mines" do
        let(:mines1) { 13 }

        it "fails validation" do
          subject.validate
          _(subject.errors[:mines]).must_include(
            "must be <= 12 (1/3 of total area)")
        end
      end

      given "too few #mines" do
        let(:width1) { 9 }
        let(:height1) { 9 }

        it "fails validation" do
          subject.validate
          _(subject.errors[:mines]).must_include(
            "must be >= 9 (10% of total area)")
        end
      end
    end
  end

  describe "#cells" do
    subject { [new_board1, win1_board].sample }

    it "sorts the association by least recent" do
      result = subject.cells.to_sql
      _(result).must_include(%(ORDER BY "cells"."created_at" ASC))
    end
  end

  describe "#pattern" do
    given "Board#pattern? = false" do
      subject { win1_board }

      it "raises ActiveRecord::RecordNotFound" do
        _(-> { subject.pattern }).must_raise(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#pattern_name" do
    given "Board#pattern? = false" do
      subject { win1_board }

      it "returns nil" do
        _(subject.pattern_name).must_be_nil
      end
    end
  end

  describe "#check_for_victory" do
    before do
      MuchStub.tap_on_call(Game::EndInVictory, :call) { |call|
        @game_end_in_victory_call = call
      }
    end

    given "the associated Game#status_sweep_in_progress? = false" do
      subject { [standing_by1_board, win1_board, loss1_board].sample }

      it "doesn't orchestrate any changes, and returns nil" do
        result = subject.check_for_victory(user: user1)
        _(result).must_be_nil
        _(@game_end_in_victory_call).must_be_nil
      end
    end

    given "the associated Game#status_sweep_in_progress? = true" do
      given "the Board is not yet in a victorious state" do
        before do
          Game::Start.(game: subject.game, user: user1, seed_cell: nil)
        end

        subject { standing_by1_board }

        it "doesn't call Game#end_in_vicotry, and returns false" do
          result = subject.check_for_victory(user: user1)
          _(result).must_equal(false)
          _(@game_end_in_victory_call).must_be_nil
        end
      end

      given "the Board is in a victorious state" do
        before do
          Game::Start.(game: subject.game, user: user1, seed_cell: nil)
          subject.cells.is_not_mine.update_all(revealed: true)
          subject.cells.reload
        end

        subject { standing_by1_board }

        it "calls Game#end_in_vicotry, and returns the Game" do
          result = subject.check_for_victory(user: user1)
          _(result).must_be_same_as(subject.game)
          _(@game_end_in_victory_call).wont_be_nil
        end
      end
    end
  end

  describe "#cells_at" do
    let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
    let(:standing_by1_board_cell2) { cells(:standing_by1_board_cell2) }

    subject { standing_by1_board }

    given "a Coordinates" do
      it "returns the expected Array" do
        _(subject.cells_at(Coordinates[0, 0])).must_equal([
          standing_by1_board_cell1,
        ])
      end
    end

    given "an Array of Coordinates" do
      it "returns the expected Array" do
        _(subject.cells_at([Coordinates[0, 0], Coordinates[1, 0]]))
          .must_equal([standing_by1_board_cell1, standing_by1_board_cell2])
      end
    end
  end

  describe "#mines_placed?" do
    given "mines present" do
      subject { win1_board }

      it "returns true" do
        _(subject.mines_placed?).must_equal(true)
      end
    end

    given "no mines present" do
      subject { standing_by1_board }

      it "returns false" do
        _(subject.mines_placed?).must_equal(false)
      end
    end
  end

  describe "#mines" do
    subject { win1_board }

    it "returns the expected Integer" do
      _(subject.mines).must_equal(1)
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

  describe "#settings" do
    subject { win1_board }

    it "returns the expected object" do
      _(subject.settings.to_h).must_equal(Board::Settings[3, 3, 1].to_h)
    end
  end
end
