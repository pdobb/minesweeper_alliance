# frozen_string_literal: true

# Metrics::Participants::MostActive::Expert represents {Game#type} = "Expert"
# for presenting Metrics on the most active {User}s.
class Metrics::Participants::MostActive::Expert
  include Metrics::Participants::MostActive::TypeBehaviors

  def type = Game::EXPERT_TYPE

  private

  def arel
    base_arel.merge(
      ParticipantTransaction.joins(:game).merge(base_game_arel.for_expert_type))
  end
end
