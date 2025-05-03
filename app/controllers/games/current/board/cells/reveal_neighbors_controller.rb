# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    # We must always dehighlight any highlighted {Cell}s, as per our game play
    # rules. So if we can't reveal neighbors (which also dehighlights), then we
    # must manually dehighlight neighbors.
    if neighbors.revealable?
      do_reveal_neighbors
    else
      Games::Current::Board::Cells::DehighlightNeighbors.(context: self)
    end
  end

  private

  def neighbors = Cell::Neighbors.new(cell:)

  def do_reveal_neighbors
    dispatch_action.call { |dispatch|
      perform_action
      dispatch.call
    }
  rescue Games::Current::Board::Cells::DispatchEffect::GameOverError
    render(turbo_stream: turbo_stream.refresh)
  end

  def dispatch_action
    @dispatch_action ||=
      Games::Current::Board::Cells::DispatchAction.new(context: self)
  end

  def perform_action
    Game::Board::RevealNeighbors.(context: action_context)
  end
end
