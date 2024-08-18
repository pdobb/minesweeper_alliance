# frozen_string_literal: true

class GamesController < ApplicationController
  def current
    current_game = Game.find_or_create_current(:beginner)
    @game_view = GameView.new(current_game)
  end

  def index
    @games = Game.not_for_status_in_progress
  end

  def show
    setup_game_view
  end

  private

  def setup_game_view
    if (game = Game.find_by(id: params[:id]))
      @game_view = GameView.new(game)
    else
      redirect_to(action: :index, alert: t("flash.not_found", type: "Game"))
    end
  end

  # GamesController::GameView is a view model for displaying {Game}s.
  class GameView
    include ViewBehaviors

    delegate :board,
             :status_in_progress?,
             to: :to_model

    def rows
      status_in_progress? ? build_active_cell_views : build_inactive_cell_views
    end

    private

    def build_active_cell_views
      cells_grid.map { |row| ActiveCellView.wrap(row) }
    end

    def build_inactive_cell_views
      cells_grid.map { |row| InactiveCellView.wrap(row) }
    end

    def cells_grid
      board.cells_grid.to_a
    end
  end

  # GamesController::CellViewBehaviors is a view model mix-in for displaying
  # {Cell}s.
  module CellViewBehaviors
    extend ActiveSupport::Concern

    include ViewBehaviors
    include WrapBehaviors

    delegate :mine?,
             :revealed?,
             :flagged?,
             to: :to_model

    def css_class
      if revealed?
        "bg-red-600" if mine?
      else # not revealed?
        "bg-slate-400"
      end
    end

    def render
      to_model.value&.delete(Cell::BLANK_VALUE).to_s
    end

    def clickable?
      raise NotImplementedError
    end
  end

  # GamesController::ActiveCellView is a view model for displaying Active
  # {Cell}s (i.e. for an In-Progress {Game}).
  class ActiveCellView
    include CellViewBehaviors

    def clickable?
      !revealed?
    end
  end

  # GamesController::InactiveCellView is a view model for displaying Inactive
  # {Cell}s (i.e. for a non-In-Progress {Game}).
  class InactiveCellView
    include CellViewBehaviors

    def clickable?
      false
    end
  end
end
