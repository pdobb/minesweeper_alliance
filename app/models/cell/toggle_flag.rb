# frozen_string_literal: true

# Cell::ToggleFlag is a Service Object for coordinating:
# - Calling of {Cell#toggle_flag} for the passed-in {Cell},
# - and then broadcasting the necessary CSS/content updates to the associated
#   Cell object in the view.
class Cell::ToggleFlag
  include CallMethodBehaviors

  def initialize(cell, user:)
    @cell = cell
    @user = user
  end

  def call
    cell.transaction do
      create_transaction_record
      toggle_flag
    end
  end

  private

  attr_reader :cell,
              :user

  def toggle_flag
    cell.toggle_flag
  end

  def create_transaction_record
    transaction_class.create_between(user:, cell:)
  end

  def transaction_class
    cell.flagged? ? CellFlagTransaction : CellUnflagTransaction
  end
end
