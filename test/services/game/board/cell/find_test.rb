# frozen_string_literal: true

require "test_helper"

class Game::Board::Cell::FindTest < ActiveSupport::TestCase
  let(:standing_by1) { games(:standing_by1) }
  let(:standing_by1_board_cell5) { cells(:standing_by1_board_cell5) }

  describe ".call" do
    subject { Game::Board::Cell::Find }

    given "a valid Cell ID" do
      let(:cell_id) { standing_by1_board_cell5.id }

      it "returns the expected Cell" do
        result = subject.(game: standing_by1, cell_id:)
        _(result).must_equal(standing_by1_board_cell5)
      end
    end

    given "an invalid Cell ID" do
      let(:cell_id) { [nil, -1, 999_999_999].sample }

      it "raises ActiveRecord::RecordNotFound" do
        exception =
          _(-> {
            subject.(game: standing_by1, cell_id:)
          }).must_raise(ActiveRecord::RecordNotFound)

        _(exception.message).must_include("-> Cell[#{cell_id.to_i}]")
      end
    end
  end
end
