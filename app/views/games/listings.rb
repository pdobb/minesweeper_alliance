# frozen_string_literal: true

# Games::Listings represents {Game} listings on the Games Index page.
class Games::Listings
  def initialize(base_arel:, type_filter:)
    @base_arel = base_arel
    @type_filter = type_filter
  end

  def any?
    arel.any?
  end

  def listings_grouped_by_date
    games_grouped_by_ended_at.
      transform_keys! { |date| ListingsDate.new(date, base_arel: arel) }.
      transform_values! { |games| Listing.wrap(games) }
  end

  private

  attr_reader :base_arel,
              :type_filter

  def games_grouped_by_ended_at
    arel.group_by { |game| game.ended_at.to_date }
  end

  def arel
    arel = base_arel
    arel = arel.for_type(type_filter) if type_filter
    arel
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

    def initialize(game)
      @game = game
    end

    def game_url
      Router.game_path(game)
    end

    def game_number = game.display_id
    def type = game.type
    def type_indicator = type[0]

    def show_game_score? = !!_game_score
    def game_score = View.round(_game_score, precision: 0)

    def game_status_mojis
      if game_ended_in_defeat?
        Emoji.mine
      elsif game_ended_in_victory?
        "#{Emoji.ship}#{Emoji.victory}"
      end
    end

    private

    attr_reader :game

    def _game_score = game.score

    def game_ended_in_victory? = game.ended_in_victory?
    def game_ended_in_defeat? = game.ended_in_defeat?
  end
end
