# frozen_string_literal: true

require "test_helper"

class Games::Current::Board::Cells::RevealsControllerTest <
        ActionDispatch::IntegrationTest
  describe "#create" do
    let(:game) { games(:standing_by1) }
    let(:board) { boards(:standing_by1_board) }
    let(:user1) { users(:user1) }

    given "the reveal uncovers the last safe cell" do
      let(:last_safe_cell) { board.cells.is_not_mine.take }

      before do
        # Cell::Find binary-searches ids, so created_at order has to follow id.
        board.cells.sort_by(&:id).each_with_index do |ordered_cell, index|
          ordered_cell.update_columns(created_at: Time.zone.at(index))
        end
        Game::Start.(game:, user: user1, seed_cell: nil)
        board.cells.is_not_mine.where.not(id: last_safe_cell.id)
          .update_all(revealed: true)
      end

      it "ends the game and swaps in the just-ended game for the revealer" do
        post(
          game_board_cell_reveal_path(game, last_safe_cell),
          as: :turbo_stream,
        )

        _(response.status).must_equal(200)
        _(game.reload.status_alliance_wins?).must_equal(true)
        _(response.body).must_include(
          %(target="#{Games::Current::Container.turbo_frame_name}"),
        )
      end
    end
  end
end
