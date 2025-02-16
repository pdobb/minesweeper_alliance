# frozen_string_literal: true

class Games::Current::Board::Cells::DehighlightNeighborsController <
        ApplicationController
  def create
    Games::Current::Board::Cells::DehighlightNeighbors.(context: self)
  end
end
