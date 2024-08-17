# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :require_game, only: :show

  def show
  end

  private

  def require_game
    game =
      Game.for_status_in_progress.take ||
        Game.create_for(:beginner)

    @game_view = GameView.new(game)
  end

  # GamesController::GameView is a view model for displaying our Game Model.
  class GameView
    include ViewBehaviors

    def rows
      cells_grid.map { |row| CellView.wrap(row) }
    end

    def board
      to_model.board
    end

    private

    def cells_grid
      board.cells_grid.to_a
    end
  end

  # GamesController::CellView
  class CellView
    include ViewBehaviors
    include WrapBehaviors

    delegate :mine?,
             :revealed?,
             to: :to_model

    def css_class
      if revealed?
        "bg-red-600" if mine?
      else # not revealed?
        "bg-slate-400"
      end
    end

    def render
      to_model.value&.delete(Cell::BLANK_VALUE)
    end
  end
end
