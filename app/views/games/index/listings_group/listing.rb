# frozen_string_literal: true

# Games::Index::ListingsGroup::Listing represents an individual {Game} listing
# on the Games Index page.
#
# Note: {#game_url} is careful to include any current {#filter_params}. This
# allows the filter(s) to carry forward. e.g. for stepping through the
# previous/next {Game}s within the same, filtered context.
class Games::Index::ListingsGroup::Listing
  include WrapMethodBehaviors

  def initialize(game, context: nil)
    @game = game
    @context = context
  end

  def game_url
    Router.game_path(game, filter_params)
  end

  def game_number = game.display_id
  def type = game.type
  def type_indicator = type[0]

  def show_score? = !!game_score
  def score = View.round(game_score, precision: 0)

  def show_active_participation_count? = game.many_active_participants?
  def active_participants_count = game.active_participants_count
  def statusmoji = past_game_view.statusmoji
  def outcome = past_game_view.outcome

  private

  attr_reader :game,
              :context

  def past_game_view = @past_game_view ||= Games::Past.new(game:)

  def game_score = game.score

  def filter_params
    return {} unless context

    context.query_parameters.slice(:type)
  end
end
