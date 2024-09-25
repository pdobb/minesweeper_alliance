# frozen_string_literal: true

class Games::Boards::ResetsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    board.reset

    broadcast_changes
    render_updated_game_board
  end
end
