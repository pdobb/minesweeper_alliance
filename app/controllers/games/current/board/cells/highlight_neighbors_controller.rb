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
  end

  private

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context: self)
  end

  def perform_effect
    cell.soft_highlight_neighborhood
  end
end
