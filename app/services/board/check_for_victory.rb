# frozen_string_literal: true

# Board::CheckForVictory updates the associated {Game}'s state to reflect a
# victiorous ending--if appplicable (based on the current {Board} state).
class Board::CheckForVictory
  def self.call(...) = new(...).call

  def initialize(board:, user:)
    @board = board
    @game = board.game
    @user = user
  end

  def call
    return unless game_status_sweep_in_progress?

    do_call
  end

  private

  attr_reader :board,
              :game,
              :user

  def game_status_sweep_in_progress? = game.status_sweep_in_progress?
  def cells = board.cells

  def do_call
    return false unless all_safe_cells_have_been_revealed?

    Game::EndInVictory.(game:, user:)
  end

  def all_safe_cells_have_been_revealed?
    cells.none? { Cell::State.safely_revealable?(it) }
  end
end
