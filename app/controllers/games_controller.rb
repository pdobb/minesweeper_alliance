# frozen_string_literal: true

class GamesController < ApplicationController
  def current
    if (current_game = Game.current)
      redirect_to(action: :show, id: current_game)
    else
      redirect_to(action: :new)
    end
  end

  def index
    @games = Game.not_for_status_in_progress.by_least_recent
  end

  def show
    setup_game
  end

  def new
  end

  def create
    current_game = Game.find_or_create_current(params[:difficulty_level])

    redirect_to(action: :show, id: current_game)
  end

  private

  def setup_game
    if (game = Game.find_by(id: params[:id]))
      @game = GameView.new(game)
    else
      redirect_to(action: :index, alert: t("flash.not_found", type: "Game"))
    end
  end

  # GamesController::GameView is a view model for displaying {Game}s.
  class GameView
    include ViewBehaviors

    def board = to_model.board
    def board_id = board.id
    def in_progress? = to_model.status_in_progress?
    def over? = to_model.over?

    def result
      status = to_model.status

      if to_model.status_mines_win?
        "#{status} #{Cell::MINE_ICON}"
      elsif to_model.status_alliance_wins?
        "#{status} ⛴️⚓️🎉"
      else
        status
      end
    end

    def board_rows
      in_progress? ? build_active_cell_views : build_inactive_cell_views
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

    BG_ERROR_COLOR = "bg-red-600"
    BG_UNREVEALED_COLOR = "bg-slate-400"

    include ViewBehaviors
    include WrapBehaviors

    def id = to_model.id
    def mine? = to_model.mine?
    def revealed? = to_model.revealed?

    def render
      to_model.value&.delete(Cell::BLANK_VALUE).to_s
    end

    def css_class
      raise NotImplementedError
    end
  end

  # GamesController::ActiveCellView is a view model for displaying Active
  # {Cell}s (i.e. for an In-Progress {Game}).
  class ActiveCellView
    include CellViewBehaviors

    def css_class
      if revealed?
        BG_ERROR_COLOR if mine?
      else # not revealed?
        BG_UNREVEALED_COLOR
      end
    end
  end

  # GamesController::InactiveCellView is a view model for displaying Inactive
  # {Cell}s (i.e. for a non-In-Progress {Game}).
  class InactiveCellView
    include CellViewBehaviors

    def flagged? = to_model.flagged?
    def incorrectly_flagged? = to_model.incorrectly_flagged?

    def render
      if revealed?
        super
      elsif flagged?
        Cell::FLAG_ICON
      elsif mine?
        Cell::MINE_ICON
      end
    end

    def css_class
      if revealed?
        BG_ERROR_COLOR if mine?
      elsif incorrectly_flagged?
        BG_ERROR_COLOR
      else
        BG_UNREVEALED_COLOR
      end
    end
  end
end
