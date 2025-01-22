# frozen_string_literal: true

require "test_helper"

class Cell::RevealTest < ActiveSupport::TestCase
  describe "Cell::Reveal" do
    let(:unit_class) { Cell::Reveal }

    let(:context1) {
      CurrentContextDouble.new(
        game: standing_by1,
        board: standing_by1_board,
        cell: standing_by1_board_cell1,
        user: user1)
    }

    let(:standing_by1) { games(:standing_by1) }
    let(:standing_by1_board) { boards(:standing_by1_board) }
    let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
    let(:user1) { users(:user1) }

    describe "#call" do
      before do
        MuchStub.on_call(Board::RandomlyPlaceMines, :call) { |call|
          @board_randomly_place_mines_call = call
        }
        MuchStub.on_call(Cell::RecursiveReveal, :call) { |call|
          @cell_recursive_reveal_call_call = call
          -> {}
        }
        MuchStub.on_call(Cell, :upsert_all) { |call|
          @cell_upsert_call = call
          Class.new { def pluck(*) = 9 }.new # standing_by1_board_cell1.id
        }
        MuchStub.on_call(standing_by1_board, :check_for_victory) { |call|
          @board_check_for_victory_call = call
        }
      end

      context "GIVEN an unrevealed Cell" do
        subject { unit_class.new(context1) }

        it "orchestrates Game state checks and Cell reveal as expected, "\
           "and returns self" do
          result =
            _(-> { subject.call }).must_change_all([
              ["standing_by1.started_at"],
              ["standing_by1.status", to: Game.status_sweep_in_progress],
              ["standing_by1_board_cell1.revealed", to: true],
              [
                -> {
                  CellRevealTransaction.exists_between?(
                    user: user1, cell: standing_by1_board_cell1)
                },
                to: true,
              ],
            ])
          _(result).must_be_same_as(subject)
          _(@board_randomly_place_mines_call).wont_be_nil
          _(@cell_recursive_reveal_call_call).wont_be_nil
          _(@cell_upsert_call).wont_be_nil
          _(@board_check_for_victory_call).wont_be_nil
        end
      end

      context "GIVEN a previously revealed Cell" do
        before do
          standing_by1_board_cell1.reveal
        end

        subject { unit_class.new(context1) }

        it "doesn't orchestrate any changes, and returns self" do
          result =
            _(-> { subject.call }).wont_change_all([
              ["standing_by1.started_at"],
              ["standing_by1.status"],
              ["standing_by1_board_cell1.revealed"],
              [
                -> {
                  CellRevealTransaction.exists_between?(
                    user: user1, cell: standing_by1_board_cell1)
                },
              ],
            ])
          _(result).must_be_same_as(subject)
          _(@board_randomly_place_mines_call).must_be_nil
          _(@cell_recursive_reveal_call_call).must_be_nil
          _(@cell_upsert_call).must_be_nil
          _(@board_check_for_victory_call).must_be_nil
        end
      end
    end
  end

  CurrentContextDouble = Class.new(Struct.new(:game, :board, :cell, :user))
end
