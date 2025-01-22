# frozen_string_literal: true

class Games::Current::Board::Cells::RevealsController < ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      result = Cell::Reveal.(current_context)

      WarRoomChannel.broadcast(
        Cell::TurboStream::Morph.wrap!(result.updated_cells, turbo_stream:))
    end

    head(:no_content)
  end
end
