# frozen_string_literal: true

# Games::Listings represents {Game} listings on the Games Index page. Listings
# may be optionally filtered by {Game#type} using `params[:type]` from the
# passed-in `context`.
class Games::Listings
  def initialize(base_arel:, context:)
    @base_arel = base_arel
    @context = context
  end

  def any? = base_arel.any?

  def listings_grouped_by_date
    games_grouped_by_ended_at.
      transform_keys! { |date| ListingsDate.new(date, base_arel:) }.
      transform_values! { |games| Listing.wrap(games, context:) }
  end

  private

  attr_reader :base_arel,
              :context

  def games_grouped_by_ended_at
    base_arel.group_by { |game| game.ended_at.to_date }
  end

  # Games::Listings::ListingsDate
  class ListingsDate
    include Games::Past::EngagementTallyBehaviors

    attr_reader :date

    def initialize(date, base_arel:)
      @date = date
      @base_arel = base_arel
    end

    def to_s
      I18n.l(date, format: :weekday_comma_date)
    end

    private

    attr_reader :base_arel

    def start_at
      date.in_time_zone.at_beginning_of_day
    end

    def end_at
      date.in_time_zone.at_end_of_day
    end
  end

  # Games::Listings::Listing
  class Listing
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

    def show_game_score? = !!_game_score
    def game_score = View.round(_game_score, precision: 0)

    def game_status_mojis = past_game.status_mojis

    private

    attr_reader :game,
                :context

    def past_game = @past_game ||= Games::Past.new(game:)

    def _game_score = game.score

    def filter_params
      return {} unless context

      context.query_parameters.slice(:type)
    end
  end
end
