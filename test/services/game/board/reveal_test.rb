# frozen_string_literal: true

require "test_helper"

class Game::Board::RevealTest < ActiveSupport::TestCase
  CurrentContextDouble = Class.new(Struct.new(:game, :board, :cell, :user))

  let(:context1) {
    CurrentContextDouble.new(
      game: standing_by1,
      board: standing_by1_board,
      cell: standing_by1_board_cell1,
      user: user2,
    )
  }

  let(:standing_by1) { games(:standing_by1) }
  let(:standing_by1_board) { boards(:standing_by1_board) }
  let(:standing_by1_board_cell1) { cells(:standing_by1_board_cell1) }
  let(:user2) { users(:user2) }

  describe "#call" do
    before do
      MuchStub.on_call(Board::RandomlyPlaceMines, :call) { |call|
        @board_randomly_place_mines_call = call
      }
      MuchStub.on_call(Game::Board::RecursiveReveal, :call) { |call|
        @cell_recursive_reveal_call_call = call
        -> {}
      }
      MuchStub.on_call(Cell, :upsert_all) { |call|
        @cell_upsert_call = call
        Class.new { def pluck(*) = 9 }.new # standing_by1_board_cell1.id
      }
      MuchStub.on_call(Board::CheckForVictory, :call) { |call|
        @board_check_for_victory_call = call
      }
    end

    given "an unrevealed Cell" do
      subject { Game::Board::Reveal.new(context: context1) }

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
                  user: user2, cell: standing_by1_board_cell1,
                )
              },
              to: true,
            ],
            [
              -> {
                ParticipantTransaction.find_between!(
                  user: user2, game: standing_by1,
                )
                  .active?
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

    given "a previously revealed Cell" do
      before do
        Cell::Reveal.(standing_by1_board_cell1)
      end

      subject { Game::Board::Reveal.new(context: context1) }

      it "doesn't orchestrate any changes, and returns self" do
        result =
          _(-> { subject.call }).wont_change_all([
            ["standing_by1.started_at"],
            ["standing_by1.status"],
            ["standing_by1_board_cell1.revealed"],
            [
              -> {
                CellRevealTransaction.exists_between?(
                  user: user2, cell: standing_by1_board_cell1,
                )
              },
            ],
            [
              -> {
                ParticipantTransaction.find_between!(
                  user: user2, game: standing_by1,
                )
                  .active?
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
