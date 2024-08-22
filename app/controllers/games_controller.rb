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
    @games =
      Game.not_for_status_in_progress.by_most_recent.
        group_by { |game| game.updated_at.to_date }
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
    def ended_in_victory? = to_model.ended_in_victory?
    def in_progress? = to_model.status_in_progress?
    def over? = to_model.over?
    def status = to_model.status
    def status_mojis = to_model.status_mojis

    def result
      return status if in_progress?

      "#{status} #{status_mojis}"
    end

    def board_rows
      build_cell_views(in_progress? ? ActiveCellView : InactiveCellView)
    end

    private

    def build_cell_views(klass)
      cells_grid.map { |row| klass.wrap(row, self) }
    end

    def cells_grid
      board.cells_grid.to_a
    end
  end

  # GamesController::CellViewBehaviors is a view model mix-in for displaying
  # {Cell}s.
  module CellViewBehaviors
    extend ActiveSupport::Concern

    BG_UNREVEALED_CELL_COLOR = "bg-slate-400"

    include ViewBehaviors
    include WrapBehaviors

    attr_reader :game

    def id = to_model.id
    def mine? = to_model.mine?
    def revealed? = to_model.revealed?
    def value = to_model.value

    def initialize(object, game)
      super(object)
      @game = game
    end

    def render
      value&.delete(Cell::BLANK_VALUE)
    end

    def css_class
      raise NotImplementedError
    end
  end

  # GamesController::ActiveCellView is a view model for displaying Active
  # {Cell}s (i.e. for an In-Progress {Game}).
  class ActiveCellView
    BG_UNREVEALED_MINE_COLOR = "bg-slate-500"

    include CellViewBehaviors

    def css_class
      return if revealed?

      if mine? && Rails.configuration.debug
        BG_UNREVEALED_MINE_COLOR
      else
        BG_UNREVEALED_CELL_COLOR
      end
    end
  end

  # GamesController::InactiveCellView is a view model for displaying Inactive
  # {Cell}s (i.e. for a non-In-Progress {Game}).
  class InactiveCellView
    BG_ERROR_COLOR = "bg-red-600"

    include CellViewBehaviors

    def flagged? = to_model.flagged?
    def incorrectly_flagged? = to_model.incorrectly_flagged?
    def game_ended_in_victory? = game.ended_in_victory?

    def render
      if revealed?
        super
      elsif flagged?
        Cell::FLAG_ICON
      elsif mine?
        game_ended_in_victory? ? Cell::FLAG_ICON : Cell::MINE_ICON
      end
    end

    def css_class
      if revealed?
        BG_ERROR_COLOR if mine?
      elsif incorrectly_flagged?
        BG_ERROR_COLOR
      else
        BG_UNREVEALED_CELL_COLOR
      end
    end
  end
end
