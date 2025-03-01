# frozen_string_literal: true

# Games::Index::ListingsGroup::EngagementTally represents the
# "Alliance vs Mines" engagements tally shown in each of the listings groups--
# grouped by date--on the Games Index page.
class Games::Index::ListingsGroup::EngagementTally
  include Games::Past::EngagementTallyBehaviors

  def initialize(date, base_arel:)
    @date = date
    @base_arel = base_arel
  end

  private

  attr_reader :date,
              :base_arel

  def start_at
    date.in_time_zone.at_beginning_of_day
  end

  def end_at
    date.in_time_zone.at_end_of_day
  end
end
