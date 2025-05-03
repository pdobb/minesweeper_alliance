# frozen_string_literal: true

class Games::Current::Board::Cells::DehighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::EffectBehaviors

  def create
    Games::Current::Board::Cells::DehighlightNeighbors.(context: self)
  rescue Games::Current::Board::Cells::DispatchEffect::GameOverError
    render(turbo_stream: turbo_stream.refresh)
  end
end
