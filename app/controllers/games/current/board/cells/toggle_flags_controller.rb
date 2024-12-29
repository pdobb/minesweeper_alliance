# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      cell.transaction do
        cell.toggle_flag
        determine_transaction_class.create_between(user: current_user, cell:)
      end

      render_updated_game
    end
  end

  private

  def determine_transaction_class
    cell.flagged? ? CellFlagTransaction : CellUnflagTransaction
  end
end
