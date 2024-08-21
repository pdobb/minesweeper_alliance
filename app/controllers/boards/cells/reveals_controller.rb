# frozen_string_literal: true

class Boards::Cells::RevealsController < ApplicationController
  include Boards::Cells::ActionBehaviors

  def create
    cell.reveal

    render_updated_game_board
  end
end
