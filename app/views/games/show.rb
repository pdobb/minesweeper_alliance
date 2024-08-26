# frozen_string_literal: true

# Games::Show is a view model for displaying the Games Show page (which is
# largely rendered by the app/views/games/_game.html.erb partial).
class Games::Show
  NULL_CELL_ID = 0

  include Games::StatusBehaviors

  def initialize(game:)
    @game = game
  end

  def turbo_stream_identifier = board
  def turbo_frame_identifer = game
  def game_status = game.status
  def game_in_progress? = game.status_in_progress?
  def game_ended_in_victory? = game.ended_in_victory?

  def status
    if game_in_progress?
      "#{game_status} #{Icon.ship}"
    else
      "#{game_status} #{game_status_mojis}"
    end
  end

  def reveal_url(router = RailsRouter.instance)
    router.game_board_cell_reveal_path(game, board, NULL_CELL_ID)
  end

  def toggle_flag_url(router = RailsRouter.instance)
    router.game_board_cell_toggle_flag_path(game, board, NULL_CELL_ID)
  end

  def reveal_neighbors_url(router = RailsRouter.instance)
    router.game_board_cell_reveal_neighbors_path(game, board, NULL_CELL_ID)
  end

  def board_rows
    build_cell_views(game_in_progress? ? ActiveCell : InactiveCell)
  end

  def elapsed_time
    @elapsed_time ||= ElapsedTime.new(game_activity_interval)
  end

  def unmarked_mines_remaining
    @unmarked_mines_remaining ||= mines_count - flags_count
  end

  def difficulty_level_name
    difficulty_level.name
  end

  def board_dimensions
    difficulty_level.dimensions
  end

  def mines_count
    difficulty_level.mines
  end

  def flag_icon = Icon.flag
  def mine_icon = Icon.mine
  def cell_icon = Icon.cell

  private

  attr_reader :game

  def board = game.board
  def difficulty_level = game.difficulty_level
  def flags_count = board.flags_count
  def game_activity_interval = game.activity_interval

  def build_cell_views(klass)
    cells_grid.map { |row| klass.wrap(row, self) }
  end

  def cells_grid
    board.cells_grid.to_a
  end

  # Games::Show::ElapsedTime is a View Model wrapper around {::ElapsedTime},
  # for displaying elapsed time details in the view template.
  class ElapsedTime
    MAX_TIME_STRING = "23:59:59+"

    attr_reader :elapsed_time

    def initialize(time_range)
      @elapsed_time = ::ElapsedTime.new(time_range)
    end

    # "Total Seconds"
    def to_i
      @to_i ||= elapsed_time.to_i
    end

    def to_s
      if over_one_day?
        MAX_TIME_STRING
      else
        I18n.l(time, format: determine_format)
      end
    end

    private

    def time
      @time ||= elapsed_time.to_time
    end

    def over_one_day? = elapsed_time.over_one_day?

    def determine_format
      if time.hour.positive?
        :hours_minutes_seconds
      elsif time.min.positive?
        :minutes_seconds
      else
        :seconds
      end
    end
  end

  # :reek:ModuleInitialize

  # Games::Show::CellBehaviors is a view model mix-in for displaying
  # {ActiveCell}s / {InactiveCell}s.
  module CellBehaviors
    extend ActiveSupport::Concern

    BG_UNREVEALED_CELL_COLOR = "bg-slate-400"

    include ActiveModelWrapperBehaviors
    include WrapMethodBehaviors

    def initialize(model, view)
      @model = model
      @view = view
    end

    def id = to_model.id
    def mine? = to_model.mine?
    def revealed? = to_model.revealed?
    def flagged? = to_model.flagged?
    def value = to_model.value

    def to_s
      value&.delete(Cell::BLANK_VALUE).to_s
    end

    def css_class
      raise NotImplementedError
    end

    private

    attr_reader :view

    def to_model = @model
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

    def incorrectly_flagged? = to_model.incorrectly_flagged?
    def game_ended_in_victory? = view.game_ended_in_victory?

    def to_s
      if revealed?
        super
      elsif flagged?
        Icon.flag
      elsif mine?
        game_ended_in_victory? ? Icon.flag : Icon.mine
      else
        ""
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
