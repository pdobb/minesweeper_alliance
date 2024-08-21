# frozen_string_literal: true

class Games::Boards::Cells::RevealsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    cell.reveal

    render_updated_game_board
  end
end
