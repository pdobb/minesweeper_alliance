# frozen_string_literal: true

class Games::Current::Board::Cells::ToggleFlagsController <
        ApplicationController
  include Games::Current::Board::Cells::ActionBehaviors

  def create
    safe_perform_game_action do
      Cell::ToggleFlag.(cell, context:)
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

    def current_user = @context.current_user
    def render_to_string(...) = @context.render_to_string(...)
    def helpers = @context.helpers
  end
end
