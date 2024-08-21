# frozen_string_literal: true

class Games::Boards::Cells::RevealNeighborsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    cell.reveal_neighbors

    render_updated_game_board
  end
end