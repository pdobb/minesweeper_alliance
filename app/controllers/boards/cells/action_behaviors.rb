# frozen_string_literal: true

# Boards::Cells::ActionBehaviors is a Controller mix-in for Controllers that
# need to operate on {Board}s and their associated {Cell}s.
module Boards::Cells::ActionBehaviors
  extend ActiveSupport::Concern

  included do
    before_action :require_board
    before_action :require_cell
  end

  private

  def require_board
    @board = Board.find(params[:board_id])
  end

  def require_cell
    @cell = @board.cells.find(params[:cell_id])
  end

  def game_id
    @board.game_id
  end
end
