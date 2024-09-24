# frozen_string_literal: true

class Games::Boards::Cells::RevealNeighborsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    Cell::RevealNeighbors.(current_context)

    broadcast_changes
    render_updated_game_board
  end
end
