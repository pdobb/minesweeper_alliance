# frozen_string_literal: true

# Games::Current::Board::Cells::DehighlightNeighbors
class Games::Current::Board::Cells::DehighlightNeighbors
  include CallMethodBehaviors

  def initialize(context:)
    @context = context
  end

  def call
    dispatch_effect.call { |dispatch|
      perform_effect
      dispatch.call
    }
  end

  private

  attr_reader :context

  def params = context.params
  def cell = context.__send__(:cell)

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context:)
  end

  def perform_effect
    cell.dehighlight_neighborhood
  end
end
