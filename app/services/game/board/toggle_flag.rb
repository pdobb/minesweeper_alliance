# frozen_string_literal: true

# Game::Board::ToggleFlag is a Service Object for coordinating:
# - Calling of {Cell#toggle_flag} for the passed-in {Cell},
# - and then broadcasting the necessary CSS/content updates to the associated
#   Cell object in the view.
class Game::Board::ToggleFlag
  def self.call(...) = new(...).call

  def initialize(context:)
    @game = context.game
    @board = context.board
    @cell = context.cell
    @user = context.user
  end

  def call
    perform_action
    self
  end

  private

  attr_reader :game,
              :board,
              :cell,
              :user

  def perform_action
    Game::Board::Lock.(game:, board:, cell:) do |fresh_cell|
      @cell = fresh_cell
      create_transaction_records
      toggle_flag
    end
  end

  def create_transaction_records
    transaction_class.create_between(user:, cell:)
    ParticipantTransaction.activate_between(user:, game:)
  end

  def toggle_flag
    Cell::ToggleFlag.(cell)
  end

  def transaction_class
    cell.flagged? ? CellUnflagTransaction : CellFlagTransaction
  end
end
