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
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def rows
      board.cells_grid.to_a.map { |row|
        row.map { |cell| CellView.new(cell) }
      }
    end

    private

    def board
      object.board
    end
  end

  # GamesController::CellView
  class CellView
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def css_background_color
      "bg-slate-300"
    end

    def render
      object.render
    end
  end
end
