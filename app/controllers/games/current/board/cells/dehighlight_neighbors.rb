# frozen_string_literal: true

# Games::Current::Board::Cells::DehighlightNeighbors
class Games::Current::Board::Cells::DehighlightNeighbors
  include CallMethodBehaviors

  def initialize(context:)
    @context = context
  end

  def call
    dispatch_effect.call { |dispatch| dispatch.(perform_effect) }
  end

  private

  attr_reader :context

  def params = context.params

  def cell = Cell.find(params[:cell_id])

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context:)
  end

  def perform_effect
    cell.highlightable_neighborhood
  end
end
