# frozen_string_literal: true

# Games::Current::Board::Cells::DehighlightNeighbors
class Games::Current::Board::Cells::DehighlightNeighbors
  include CallMethodBehaviors

  def initialize(context:)
    @context = context
  end

  def call
    passive_response_generator << cell.highlightable_neighborhood
    passive_response_generator.call
  end

  private

  attr_reader :context

  def params = context.params

  def cell = Cell.find(params[:cell_id])

  def passive_response_generator
    @passive_response_generator ||=
      Games::Current::Board::Cells::GeneratePassiveResponse.new(context:)
  end
end
