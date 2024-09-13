# frozen_string_literal: true

class Games::Boards::Cells::ToggleFlagsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    cell.transaction do
      cell.toggle_flag
      determine_transaction_class.create_between(user: current_user, cell:)
    end

    broadcast_changes
    render_updated_game_board
  end

  private

  def determine_transaction_class
    cell.flagged? ? CellFlagTransaction : CellUnflagTransaction
  end
end
