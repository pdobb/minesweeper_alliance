# frozen_string_literal: true

# Games::JustEnded::Results represents end-of-{Game} results (metrics + Duty
# Roster) for just-ended {Game}s.
class Games::JustEnded::Results
  def initialize(game:)
    @game = game
  end

  def metrics
    Games::Past::Metrics.new(game:)
  end

  def active_participants_roster
    Games::JustEnded::ActiveParticipants::Roster.new(game:)
  end

  def observers_roster
    Games::JustEnded::Observers::Roster.new(game:)
  end

  private

  attr_reader :game
end
