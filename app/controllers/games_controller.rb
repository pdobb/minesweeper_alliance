# frozen_string_literal: true

class GamesController < ApplicationController
  def show
    current_game = Game.find_or_create_current(:beginner)
    @game_view = GameView.new(current_game)
  end

  # GamesController::GameView is a view model for displaying {Game}s.
  class GameView
    include ViewBehaviors

    delegate :board,
             to: :to_model

    def rows
      cells_grid.map { |row| CellView.wrap(row) }
    end

    private

    def cells_grid
      board.cells_grid.to_a
    end
  end

  # GamesController::CellView is a view model for display {Cell}s.
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
