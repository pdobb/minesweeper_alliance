# frozen_string_literal: true

# EngagementTally is a Service Object for tallying the numbers of {Game} wins vs
# losses over a given time period. The period defaults to "today" (start of day
# in Central Time, up until now).
class EngagementTally
  include CallMethodBehaviors

  attr_reader :start_time,
              :end_time

  def initialize(between = nil.., base_arel: Game)
    now = Time.current
    @start_time = between.begin || now.at_beginning_of_day
    @end_time = between.end || now
    @base_arel = base_arel
  end

  def to_h
    { wins: wins_count, losses: losses_count }
  end

  def to_s
    "Alliance: #{wins_count} / Mines: #{losses_count}"
  end

  def wins_count
    @wins_count ||= arel.rewhere(status: Game.status_alliance_wins).count
  end

  def losses_count
    @losses_count ||= arel.rewhere(status: Game.status_mines_win).count
  end

  def alliance_leads?
    wins_count > losses_count
  end

  def mines_lead?
    losses_count > wins_count
  end

  private

  attr_reader :base_arel

  def arel
    base_arel.readonly.for_ended_at(time_period)
  end

  def time_period
    start_time..end_time
  end
end
