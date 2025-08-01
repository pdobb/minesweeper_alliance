# frozen_string_literal: true

require "test_helper"

class Board::Calc3BVTest < ActiveSupport::TestCase
  let(:win1_board) { boards(:win1_board) }

  let(:custom_game1_board) { custom_game1.board }
  let(:custom_game1) {
    Game::Factory.create_for(
      settings: Board::Settings.pattern("3BV Test Pattern 1"),
    )
  }

  describe ".call" do
    subject { Board::Calc3BV }

    given "a simplistic board" do
      it "returns the expected Integer" do
        result = subject.call(win1_board.grid)

        _(result).must_equal(1)
      end
    end
  end
end
