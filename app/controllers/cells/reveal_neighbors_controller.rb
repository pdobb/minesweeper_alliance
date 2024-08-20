# frozen_string_literal: true

class Cells::RevealNeighborsController < ApplicationController
  include CellActionBehaviors

  def create
    result = @cell.reveal_neighbors

    redirect_to(game_path(result.game))
  end
end
