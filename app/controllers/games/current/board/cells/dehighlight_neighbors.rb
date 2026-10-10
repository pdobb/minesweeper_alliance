# frozen_string_literal: true

# Games::Current::Board::Cells::DehighlightNeighbors
class Games::Current::Board::Cells::DehighlightNeighbors
  # Pass the block on its own. Forwarding `...` into both calls gives {#call}
  # the block as a positional argument and raises ArgumentError.
  def self.call(context:, &) = new(context:).call(&)

  def initialize(context:)
    @context = context
  end

  def call
    dispatch_effect.call { |dispatch|
      yield
      dispatch.call
    }
  end

  private

  attr_reader :context

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context:)
  end
end
