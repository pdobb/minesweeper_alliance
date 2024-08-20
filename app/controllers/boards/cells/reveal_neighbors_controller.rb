# frozen_string_literal: true

class Boards::Cells::RevealNeighborsController < ApplicationController
  include Boards::Cells::ActionBehaviors

  def create
    @cell.reveal_neighbors

    redirect_to(game_path(game_id))
  end
end
