# frozen_string_literal: true

require "test_helper"

class Game::Board::LockTest < ActiveSupport::TestCase
  describe ".call" do
    subject { Game::Board::Lock }

    given "the rendered cell collection is stale" do
      let(:game) { games(:standing_by1) }
      let(:board) { boards(:standing_by1_board) }
      let(:cell) { cells(:standing_by1_board_cell1) }
      let(:sibling_cell) { cells(:standing_by1_board_cell2) }

      before do
        board.cells.load
        Cell.where(id: [cell.id, sibling_cell.id]).update_all(revealed: true)
      end

      it "yields the committed cells from the collection the view renders" do
        yielded_cell = nil

        subject.call(game:, board:, cell:) do |fresh_cell|
          yielded_cell = fresh_cell
        end

        _(yielded_cell.revealed?).must_equal(true)
        _(yielded_cell).must_be_same_as(
          board.cells.detect { |candidate| candidate.id == cell.id },
        )
        _(
          board.cells.detect { |candidate|
            candidate.id == sibling_cell.id
          }.revealed?,
        ).must_equal(true)
        _(board.version).must_equal(1)
        _(game.board).must_be_same_as(board)
        _(board.game).must_be_same_as(game)
        _(Games::Current::Board::Content.new(board:).version).must_equal(1)
      end
    end

    given "the game is over" do
      let(:game) { games(:loss1) }
      let(:board) { boards(:loss1_board) }
      let(:cell) { cells(:loss1_board_cell1) }

      it "marks the rendered cells readonly" do
        readonly = nil

        subject.call(game:, board:, cell:) do |fresh_cell|
          readonly = fresh_cell.readonly?
        end

        _(readonly).must_equal(true)
      end
    end
  end
end
