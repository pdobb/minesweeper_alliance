# frozen_string_literal: true

class Cells::RevealsController < ApplicationController
  include CellActionBehaviors

  def create
    result = @cell.reveal

    if result.game_in_progress?
      redirect_to(root_path)
    else
      redirect_to(game_path(result.game))
    end
  end
end
