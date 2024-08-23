# frozen_string_literal: true

# Games::Show is a view model for displaying the Games Show page (which is
# largely rendered by the app/views/games/_game.html.erb partial).
class Games::Show
  include Games::StatusBehaviors

  # FIXME: Make private.
  attr_reader :game

  # FIXME: Make private.
  def board = game.board

  def initialize(game:)
    @game = game
  end

  def turbo_stream_identifier = board
  def turbo_frame_identifer = game
  def game_in_progress? = game.status_in_progress?
  def game_status = game.status
  def game_ended_in_victory? = game.ended_in_victory?

  def game_result
    return game_status if game_in_progress?

    "#{game_status} #{game_status_mojis}"
  end

  def random_cell_id_for_reveal
    board.random_cell_id_for_reveal.to_i
  end

  def board_rows
    build_cell_views(game_in_progress? ? ActiveCell : InactiveCell)
  end

  private

  def build_cell_views(klass)
    cells_grid.map { |row| klass.wrap(row, self) }
  end

  def cells_grid
    board.cells_grid.to_a
  end

  # Games::Show::CellBehaviors is a view model mix-in for displaying
  # {ActiveCell}s / {InactiveCell}s.
  module CellBehaviors
    extend ActiveSupport::Concern

    BG_UNREVEALED_CELL_COLOR = "bg-slate-400"

    include ActiveModelWrapperBehaviors
    include WrapBehaviors

    attr_reader :view

    def id = to_model.id
    def mine? = to_model.mine?
    def revealed? = to_model.revealed?
    def value = to_model.value

    def initialize(object, view)
      super(object)
      @view = view
    end

    def render
      value&.delete(Cell::BLANK_VALUE)
    end

    def css_class
      raise NotImplementedError
    end
  end

  # Games::Show::ActiveCell is a view model for displaying Active {Cell}s. i.e.
  # for an In-Progress {Game}.
  class ActiveCell
    BG_UNREVEALED_MINE_COLOR = "bg-slate-500"

    include CellBehaviors

    def css_class
      return if revealed?

      if mine? && Rails.configuration.debug
        BG_UNREVEALED_MINE_COLOR
      else
        BG_UNREVEALED_CELL_COLOR
      end
    end
  end

  # Games::Show::InactiveCell is a view model for displaying Inactive {Cell}s.
  # i.e. for a {Game} that's no longer In-Progress.
  class InactiveCell
    BG_ERROR_COLOR = "bg-red-600"

    include CellBehaviors

    def flagged? = to_model.flagged?
    def incorrectly_flagged? = to_model.incorrectly_flagged?
    def game_ended_in_victory? = view.game_ended_in_victory?

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
