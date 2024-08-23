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
    @view = Index.new
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

  # GamesController::GameViewBehaviors
  module GameViewBehaviors
    def ended_in_victory? = to_model.ended_in_victory?

    def status_mojis
      if ended_in_victory?
        "⛴️⚓️🎉"
      else # ended_in_defeat?
        Cell::MINE_ICON
      end
    end
  end

  # GamesController::Index is a view model for displaying the Games Index page.
  class Index
    def current_time_zone_description
      Rails.configuration.time_zone
    end

    def listings_grouped_by_date
      GroupListings.(games_grouped_by_date)
    end

    private

    def games_grouped_by_date
      games_arel.group_by { |game| game.updated_at.to_date }
    end

    def games_arel
      Game.not_for_status_in_progress.by_most_recent
    end

    # GamesController::Index::GroupListings
    class GroupListings
      include CallMethodBehaviors

      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def on_call
        hash.
          transform_keys! { |date| ListingsDate.new(date) }.
          transform_values! { |games| Listing.wrap(games) }
      end
    end

    # GamesController::Index::ListingsDate
    class ListingsDate
      attr_reader :date

      def initialize(date)
        @date = date
      end

      def to_s
        I18n.l(date, format: :weekday_comma_date)
      end
    end

    # GamesController::Index::Listing
    class Listing
      include WrapBehaviors
      include ActiveModelWrapperBehaviors
      include GameViewBehaviors

      def id = to_model.id

      def game_number
        id.to_s.rjust(4, "0")
      end

      def game_timestamp
        I18n.l(to_model.updated_at, format: :time)
      end
    end
  end

  # GamesController::GameView is a view model for displaying {Game}s.
  class GameView
    include ViewBehaviors
    include GameViewBehaviors

    def board = to_model.board
    def board_id = board.id
    def in_progress? = to_model.status_in_progress?
    def over? = to_model.over?
    def status = to_model.status

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
