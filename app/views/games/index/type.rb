# frozen_string_literal: true

# Games::Index::Type wraps {Game::TYPES}, for display of the
# "<Initials> = <Name>" map/legend + filter links on the Games Index page.
class Games::Index::Type
  include WrapMethodBehaviors

  def initialize(name, type_filter:)
    @name = name
    @type_filter = type_filter
  end

  def filter_name
    "(#{name.first})#{name[1..]}"
  end

  def games_filter_url
    if filter_active?
      Router.games_path
    else
      Router.games_path(type: name)
    end
  end

  def css
    "active" if filter_active?
  end

  def games_count = @games_count ||= base_arel.for_type(name).count

  def games_percentage
    View.percentage(games_percent, precision: 0)
  end

  private

  attr_reader :name,
              :type_filter

  def base_arel = Game.for_game_over_statuses.is_not_spam

  def filter_active?
    type_filter&.include?(name)
  end

  def games_percent
    result = (games_count / total_games_count.to_f) * 100.0
    result.nan? ? 0.0 : result
  end

  def total_games_count = @total_games_count ||= base_arel.count
end
