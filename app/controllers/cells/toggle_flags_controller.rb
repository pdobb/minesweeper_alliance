# frozen_string_literal: true

class Cells::ToggleFlagsController < ApplicationController
  include CellActionBehaviors

  def create
    result = @cell.toggle_flag

    redirect_to(game_path(result.game))
  end
end
