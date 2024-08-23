# frozen_string_literal: true

# Games::Index is a view model for displaying the Games Index page.
class Games::Index
  attr_reader :base_arel

  def self.current_time_zone_description
    Rails.configuration.time_zone
  end

  def initialize(base_arel:)
    @base_arel = base_arel
  end

  def current_time_zone_description = self.class.current_time_zone_description

  def listings_grouped_by_date
    GroupListings.(games_grouped_by_date)
  end

  private

  def games_grouped_by_date
    base_arel.group_by { |game| game.updated_at.to_date }
  end

  # Games::Index::GroupListings is a Service Object for combining
  # {Games::Index::ListingsDate}s with {Games::Index::Listing}s.
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

  # Games::Index::ListingsDate
  class ListingsDate
    attr_reader :date

    def initialize(date)
      @date = date
    end

    def to_s
      I18n.l(date, format: :weekday_comma_date)
    end
  end

  # Games::Index::Listing
  class Listing
    include WrapBehaviors
    include ActiveModelWrapperBehaviors
    include GamesController::GameViewBehaviors

    def id = to_model.id

    def game_number
      id.to_s.rjust(4, "0")
    end

    def game_timestamp
      I18n.l(to_model.updated_at, format: :time)
    end
  end
end
