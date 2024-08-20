# frozen_string_literal: true

class Boards::Cells::ToggleFlagsController < ApplicationController
  include Boards::Cells::ActionBehaviors

  def create
    @cell.toggle_flag

    redirect_to(game_path(game_id))
  end
end
