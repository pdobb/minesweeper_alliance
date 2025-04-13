# frozen_string_literal: true

require "test_helper"

class Board::GenerateTest < ActiveSupport::TestCase
  let(:standing_by1_board) { boards(:standing_by1_board) }

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
      now + (index * 0.00001r)
    end

    subject { Board::Generate.new(board: standing_by1_board) }

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
