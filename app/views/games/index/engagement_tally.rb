# frozen_string_literal: true

# Games::Index::EngagementTally represents the various "Alliance vs Mines"
# engagements tallies shown on the Games Index page.
class Games::Index::EngagementTally
  include Games::Past::EngagementTallyBehaviors

  def initialize(base_arel:)
    @base_arel = base_arel
  end

  private

  attr_reader :base_arel

  def start_at = App.created_at
end
