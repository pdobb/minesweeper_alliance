# frozen_string_literal: true

class Boards::Cells::ToggleFlagsController < ApplicationController
  include Boards::Cells::ActionBehaviors

  def create
    cell.toggle_flag

    render_updated_game_board
  end
end
