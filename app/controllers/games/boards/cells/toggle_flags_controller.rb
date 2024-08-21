# frozen_string_literal: true

class Games::Boards::Cells::ToggleFlagsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    cell.toggle_flag

    render_updated_game_board
  end
end
