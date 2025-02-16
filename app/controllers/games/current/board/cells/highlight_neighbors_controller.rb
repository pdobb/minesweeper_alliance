# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  rate_limit to: 3, within: 1.second

  def create
    response_generator << cell.soft_highlight_neighborhood
    response_generator.call
  end

  private

  def cell = Cell.find(params[:cell_id])

  def response_generator
    @response_generator ||=
      Games::Current::Board::Cells::GeneratePassiveResponse.new(context: self)
  end
end
