# frozen_string_literal: true

class Games::Current::Board::Cells::RevealNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      # Whether we end up revealing any neighboring {Cell}s or not, we will
      # always need to dehighlight any highlighted neighboring {Cell}s as per
      # our game play rules.
      # - If neighbors are revealed, {Cell#reveal} takes care of the
      #   de-highlighting of those {Cell}s for us.
      # - Else, we must take care of this here ourselves.
      if cell.neighboring_flags_count_matches_value?
        Cell::RevealNeighbors.(current_context)

        render_updated_game
      else
        Cell::DehighlightNeighbors.(
          cell, context: dehighlight_neighbors_context)
      end
    end
  end

  private

  def dehighlight_neighbors_context = Context.new(self)

  # Games::Current::Board::Cells::RevealNeighborsController::Context
  class Context
    def initialize(context)
      @context = context
    end

    def helpers = @context.helpers
  end
end
