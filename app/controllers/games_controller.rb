# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :require_game, only: :show

  def show
    @board = @game.board
  end

  private

  def require_game
    @game =
      Game.for_status_in_progress.take ||
        Game.create_for(:beginner)
  end
end
