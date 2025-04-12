# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    # We must always dehighlight any highlighted {Cell}s, as per our game play
    # rules. So if we can't reveal neighbors (which also dehighlights), then we
    # must manually dehighlight neighbors.
    if neighbors.revealable?
      dispatch_action.call { |dispatch|
        perform_action
        dispatch.call
      }
    else
      Games::Current::Board::Cells::DehighlightNeighbors.(context: self)
    end
  end

  private

  def neighbors = Cell::Neighbors.new(cell:)

  def dispatch_action
    @dispatch_action ||=
      Games::Current::Board::Cells::DispatchAction.new(context: self)
  end

  def perform_action
    Cell::RevealNeighbors.(context: action_context)
  end
end
