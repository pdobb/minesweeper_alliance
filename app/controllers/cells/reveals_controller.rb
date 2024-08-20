# frozen_string_literal: true

class Cells::RevealsController < ApplicationController
  include CellActionBehaviors

  def create
    result = @cell.reveal

    redirect_to(game_path(result.game))
  end
end
