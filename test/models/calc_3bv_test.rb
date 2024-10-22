# frozen_string_literal: true

require "test_helper"

class Calc3BVTest < ActiveSupport::TestCase
  describe "Calc3BV" do
    let(:unit_class) { Calc3BV }

    let(:win1_board) { boards(:win1_board) }

    let(:custom_game1_board) { custom_game1.board }
    let(:custom_game1) {
      Game.create_for(settings: Board::Settings.pattern("3BV Test Pattern 1"))
    }

    describe ".call" do
      subject { unit_class }

      context "GIVEN a simplistic board" do
        it "returns the expected Integer" do
          result = subject.call(win1_board.grid)
          _(result).must_equal(1)
        end
      end
    end
  end
end
