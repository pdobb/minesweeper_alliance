# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::EffectBehaviors

  rate_limit to: 3, within: 1.second

  def create
    dispatch_effect.call { |dispatch|
      perform_effect
      dispatch.call
    }
  rescue Games::Current::Board::Cells::DispatchEffect::GameOverError
    render(turbo_stream: turbo_stream.refresh)
  end

  private

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context: self)
  end

  def perform_effect
    game.with_lock do
      Cell::HighlightNeighborhood.(cell)
    end
  end
end
