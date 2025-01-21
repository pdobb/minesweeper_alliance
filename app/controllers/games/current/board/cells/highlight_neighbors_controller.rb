# frozen_string_literal: true

class Games::Current::Board::Cells::HighlightNeighborsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      Cell::HighlightNeighbors.(cell, context:)
    end

    head(:no_content)
  end

  private

  def context = Context.new(self)

  # Games::Current::Board::Cells::HighlightNeighborsController::Context
  class Context
    def initialize(context)
      @context = context
    end

    def helpers = @context.helpers
  end
end
