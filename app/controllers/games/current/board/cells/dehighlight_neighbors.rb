# frozen_string_literal: true

# Games::Current::Board::Cells::DehighlightNeighbors
class Games::Current::Board::Cells::DehighlightNeighbors
  def self.call(...) = new(...).call

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
  def game = context.__send__(:game)
  def cell = context.__send__(:cell)

  def perform_effect
    game.with_lock do
      Cell::DehighlightNeighborhood.(cell)
    end
  end

  def dispatch_effect
    @dispatch_effect ||=
      Games::Current::Board::Cells::DispatchEffect.new(context:)
  end
end
