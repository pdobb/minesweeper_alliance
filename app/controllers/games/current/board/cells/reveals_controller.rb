# frozen_string_literal: true

class Games::Current::Board::Cells::RevealsController < ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    updated_cells =
      safe_perform_game_action {
        Cell::Reveal.(current_context).updated_cells
      }

    broadcast_updates([cell, updated_cells])
  end
end
