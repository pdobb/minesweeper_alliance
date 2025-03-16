# frozen_string_literal: true

# Cell::ToggleFlag is a Service Object for coordinating:
# - Calling of {Cell#toggle_flag} for the passed-in {Cell},
# - and then broadcasting the necessary CSS/content updates to the associated
#   Cell object in the view.
class Cell::ToggleFlag
  include CallMethodBehaviors

  def initialize(context:)
    @game = context.game
    @cell = context.cell
    @user = context.user
  end

  def call
    game.with_lock do
      create_transaction_records
      toggle_flag
    end

    self
  end

  private

  attr_reader :game,
              :cell,
              :user

  def toggle_flag = cell.toggle_flag

  def create_transaction_records
    transaction_class.create_between(user:, cell:)
    ParticipantTransaction.activate_between(user:, game:)
  end

  def transaction_class
    cell.flagged? ? CellUnflagTransaction : CellFlagTransaction
  end
end
