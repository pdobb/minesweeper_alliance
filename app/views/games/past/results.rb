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

  def active_participants_roster
    Games::Past::ActiveParticipants::Roster.new(game:)
  end

  def observers_roster
    Games::Past::Observers::Roster.new(game:)
  end

  private

  attr_reader :game
end
