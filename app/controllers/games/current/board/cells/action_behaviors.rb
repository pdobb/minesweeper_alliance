# frozen_string_literal: true

# Games::Current::Board::Cells::ActionBehaviors abstracts the basic contextual
# methods used by the various Cell Action controllers.
module Games::Current::Board::Cells::ActionBehaviors
  include Games::Current::Board::Cells::Behaviors

  private

  def action_context = ActionContext.new(self)

  # Games::Current::Board::Cells::ActionBehaviors::ActionContext services the
  # needs of the Cell Action service objects called by including controllers.
  # i.e. {Game::Board::Reveal}, {Game::Board::RevealNeighbors}, and
  # {Game::Board::ToggleFlag}.
  class ActionContext
    def initialize(context) = @context = context

    def game = context.__send__(:game)
    def board = context.__send__(:board)
    def cell = context.__send__(:cell)
    def user = context.current_user

    private

    attr_reader :context
  end
end
