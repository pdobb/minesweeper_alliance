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
    all_day.begin
  end

  def end_at
    all_day.end
  end

  def all_day
    @all_day ||= date.in_time_zone.all_day
  end
end
