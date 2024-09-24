# frozen_string_literal: true

class Games::Boards::Cells::RevealsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    Cell::Reveal.(current_context)

    broadcast_changes
    render_updated_game_board
  end
end
