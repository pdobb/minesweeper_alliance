# frozen_string_literal: true

# Games::Past::PageNav handles page-level navigation between past {Game}s.
class Games::Past::PageNav
  def initialize(game:, context:)
    @game = game
    @context = context
  end

  def breadcrumb_name
    [
      "Archive",
      ("(#{display_filters})" if filter_params?),
    ].tap(&:compact!).join(" ")
  end

  def show_close_button? = true
  def close_game_url = Router.games_path(filter_params)

  def previous_game? = !!previous_game
  def previous_game_url = Router.game_path(previous_game, filter_params)

  def next_game? = next_game&.over?
  def next_game_url = Router.game_path(next_game, filter_params)

  private

  attr_reader :game,
              :context

  def previous_game = Game::Navigator.previous(game:, base_arel:)
  def next_game = Game::Navigator.next(game:, base_arel:)

  def base_arel
    arel = Game.is_not_spam
    arel = arel.for_type(type_filter) if type_filter_params?
    arel
  end

  def display_filters
    type_filter
  end

  def type_filter = filter_params[:type]

  def filter_params
    @filter_params ||= query_parameters.slice(:type)
  end

  def filter_params? = filter_params.any?
  def type_filter_params? = filter_params.key?(:type)

  def query_parameters = context.query_parameters
end
