# frozen_string_literal: true

class Games::Current::Board::Cells::DehighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::EffectBehaviors

  def create
    Games::Current::Board::Cells::DehighlightNeighbors.(context: self) do
      perform_effect
    end
  rescue Games::Current::Board::Cells::DispatchEffect::GameOverError
    render(turbo_stream: turbo_stream.refresh)
  end

  private

  def perform_effect
    Game::Board::Lock.(game:, board:, cell:) do |fresh_cell|
      Cell::DehighlightNeighborhood.(fresh_cell)
    end
  end
end
