# frozen_string_literal: true

# Games::Past::EngagementTallyBehaviors mixes in View Model behaviors for
# objects that wrap {EngagementTally}.
module Games::Past::EngagementTallyBehaviors
  def wins_count = engagement_tally.wins_count
  def losses_count = engagement_tally.losses_count
  def alliance_leads? = engagement_tally.alliance_leads?
  def mines_lead? = engagement_tally.mines_lead?

  def alliance_ranking_css
    if alliance_leads?
      %w[text-green-700 dark:text-green-600]
    elsif mines_lead?
      %w[text-red-700 dark:text-red-600]
    end
  end

  def engagement_tally
    @engagement_tally ||= ::EngagementTally.new(start_at..end_at, base_arel:)
  end

  private

  def start_at
    raise(NotImplementedError)
  end

  def end_at
    nil
  end

  def base_arel
    raise(NotImplementedError)
  end
end
