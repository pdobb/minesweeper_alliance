# frozen_string_literal: true

class Boards::Cells::RevealNeighborsController < ApplicationController
  include Boards::Cells::ActionBehaviors

  def create
    cell.reveal_neighbors

    render_updated_game_board
  end
end
