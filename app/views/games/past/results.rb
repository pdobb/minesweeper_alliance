# frozen_string_literal: true

# Games::Past::Results represents end-of-{Game} results (metrics + Duty Roster)
# for past {Game}s.
class Games::Past::Results
  def initialize(game:)
    @game = game
  end

  def metrics
    Games::Past::Metrics.new(game:)
  end

  def duty_roster
    Games::Past::Participants::DutyRoster.new(game:)
  end

  private

  attr_reader :game
end
