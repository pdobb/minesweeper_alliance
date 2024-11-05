# frozen_string_literal: true

class Games::Current::Board::Cells::RevealsController < ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    Cell::Reveal.(current_context)

    broadcast_changes
    render_updated_game
  end
end
