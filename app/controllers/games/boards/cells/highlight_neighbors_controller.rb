# frozen_string_literal: true

class Games::Boards::Cells::HighlightNeighborsController < ApplicationController
  include Games::Boards::Cells::ActionBehaviors

  def create
    cell.highlight_neighbors

    render_updated_game_board
  end
end
