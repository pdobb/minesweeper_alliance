# frozen_string_literal: true

# Games::Show is a View Model for displaying the Games Show page (which is
# largely rendered by the app/views/games/_game.html.erb partial).
class Games::Show
  NULL_CELL_ID = 0

  include Games::ShowBehaviors
  include Games::StatusBehaviors

  def self.broadcast_players_count_update(stream_name:, count:)
    WarRoomChannel.broadcast_update_to(
      stream_name, target: "fleet_count", html: [count, 1].max)
  end

  def initialize(game:)
    @game = game
  end

  def nav = Nav.new(game:)

  def cache_name(context:)
    [
      game,
      context.mobile? ? :mobile : :web,
    ]
  end

  def current_game? = game_on? || game_just_ended?
  def game_on? = game.on?
  def game_just_ended? = game.just_ended?

  def game_status_css_class
    if game.status_alliance_wins?
      %w[text-green-700 dark:text-green-600]
    elsif game.status_mines_win?
      %w[text-red-700 dark:text-red-600]
    end
  end

  def game_status = game.status

  def players_count(roster = DutyRoster)
    [roster.count, 1].max
  end

  def flags_count = board.flags_count
  def mines = board.mines

  def reveal_url(router = RailsRouter.instance)
    router.game_board_cell_reveal_path(game, board, NULL_CELL_ID)
  end

  def toggle_flag_url(router = RailsRouter.instance)
    router.game_board_cell_toggle_flag_path(game, board, NULL_CELL_ID)
  end

  def highlight_neighbors_url(router = RailsRouter.instance)
    router.game_board_cell_highlight_neighbors_path(game, board, NULL_CELL_ID)
  end

  def reveal_neighbors_url(router = RailsRouter.instance)
    router.game_board_cell_reveal_neighbors_path(game, board, NULL_CELL_ID)
  end

  def rows(context:)
    klass = game_on? ? ActiveCell : InactiveCell

    grid(context:).map { |row| klass.wrap(row, self) }
  end

  def grid_context(context)
    @grid_context ||= Games::GridContext.new(context:, board:)
  end

  def elapsed_time
    @elapsed_time ||= ElapsedTime.new(game_engagement_time_range)
  end

  def board_dimensions = board.dimensions

  def results(user:)
    Games::Results.new(game:, user:)
  end

  private

  attr_reader :game

  def to_model = game
  def board = game.board

  def grid(context:)
    @grid ||= board.grid(context:)
  end

  def game_engagement_time_range = game.engagement_time_range

  # Games::Show::Nav is a View Model for handling navigation between Game - Show
  # pages.
  class Nav
    def initialize(game:)
      @game = game
    end

    def close_game_url(router = RailsRouter.instance)
      router.games_path
    end

    def previous_game? = !!previous_game

    def previous_game_url(router = RailsRouter.instance)
      router.game_path(previous_game)
    end

    def next_game? = next_game&.over?

    def next_game_url(router = RailsRouter.instance)
      router.game_path(next_game)
    end

    private

    attr_reader :game

    def previous_game
      @previous_game ||=
        base_arel.for_created_at(..game.created_at).by_most_recent.take
    end

    def next_game
      @next_game ||=
        base_arel.for_created_at(game.created_at..).by_least_recent.take
    end

    def base_arel
      Game.excluding(game).limit(1)
    end
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
      if over_a_day?
        MAX_TIME_STRING
      else
        I18n.l(time, format: determine_format)
      end
    end

    private

    def time
      @time ||= elapsed_time.to_time
    end

    def over_a_day? = elapsed_time.over_a_day?

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

  # Games::Show::CellBehaviors is a View Model mix-in for displaying
  # {ActiveCell}s / {InactiveCell}s.
  module CellBehaviors
    extend ActiveSupport::Concern

    BG_UNREVEALED_CELL_COLOR = "bg-slate-400 dark:bg-neutral-700"

    include ActiveModelWrapperBehaviors
    include WrapMethodBehaviors

    def id = to_model.id
    def mine? = to_model.mine?
    def revealed? = to_model.revealed?
    def flagged? = to_model.flagged?
    def blank? = to_model.blank?
    def value = to_model.value

    def to_s
      if blank?
        ""
      elsif value
        value.to_s
      elsif flagged?
        Icon.flag
      else # rubocop:disable Lint/DuplicateBranch
        ""
      end
    end

    def css_classes
      raise NotImplementedError
    end

    private

    def to_model = @model
  end

  # Games::Show::ActiveCell is a View Model for displaying Active {Cell}s. i.e.
  # for an In-Progress {Game}.
  class ActiveCell
    BG_HIGHLIGHTED_COLOR = %w[bg-slate-300 dark:bg-neutral-500].freeze
    HIGHLIGHTED_ANIMATION = "animate-pulse-fast"
    BG_UNREVEALED_MINE_COLOR = %w[bg-slate-500 dark:bg-neutral-900].freeze

    include CellBehaviors

    def initialize(model, _show_view)
      @model = model
    end

    def unrevealed? = !to_model.revealed?
    def highlighted? = to_model.highlighted?

    def css_classes
      if highlighted?
        [BG_HIGHLIGHTED_COLOR, HIGHLIGHTED_ANIMATION]
      elsif mine? && App.debug?
        BG_UNREVEALED_MINE_COLOR
      elsif unrevealed?
        BG_UNREVEALED_CELL_COLOR
      end
    end
  end

  # Games::Show::InactiveCell is a View Model for displaying Inactive {Cell}s.
  # i.e. for a {Game} that's no longer In-Progress.
  class InactiveCell
    # rubocop:disable Layout/MultilineArrayLineBreaks
    BG_ERROR_COLOR = %w[
      bg-red-600 dark:bg-red-800
      shadow-inner shadow-slate-600 dark:shadow-neutral-800
    ].freeze
    # rubocop:enable Layout/MultilineArrayLineBreaks
    DIMMED_TEXT_COLOR = %w[text-gray-400 dark:text-neutral-600].freeze

    include CellBehaviors

    def initialize(model, show_view)
      @model = model
      @show_view = show_view
    end

    def incorrectly_flagged? = to_model.incorrectly_flagged?
    def game_ended_in_victory? = show_view.game_ended_in_victory?

    # :reek:DuplicateMethodCall

    def to_s
      return super unless mine?

      # if mine? && ...
      if revealed?
        Icon.mine
      elsif flagged?
        Icon.flag
      else
        game_ended_in_victory? ? Icon.flag : Icon.mine
      end
    end

    def css_classes
      if revealed?
        mine? ? BG_ERROR_COLOR : DIMMED_TEXT_COLOR
      elsif incorrectly_flagged?
        BG_ERROR_COLOR
      elsif !flagged?
        BG_UNREVEALED_CELL_COLOR
      end
    end

    private

    attr_reader :show_view
  end
end
