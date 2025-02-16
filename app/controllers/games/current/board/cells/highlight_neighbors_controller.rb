# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  rate_limit to: 3, within: 1.second

  def create
    dispatch_effect.call { |dispatch| dispatch.(perform_effect) }
  end

  private

  def cell = Cell.find(params[:cell_id])

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context: self)
  end

  def perform_effect
    cell.soft_highlight_neighborhood
  end
end
