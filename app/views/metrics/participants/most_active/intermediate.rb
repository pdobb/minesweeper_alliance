# frozen_string_literal: true

# Metrics::Participants::MostActive::Intermediate represents
# {Game#type} = "Intermediate" for presenting Metrics on the most active
# {User}s.
class Metrics::Participants::MostActive::Intermediate
  include Metrics::Participants::MostActive::TypeBehaviors

  def type = Game::INTERMEDIATE_TYPE

  private

  def arel
    base_arel.merge(
      ParticipantTransaction.joins(:game).merge(
        base_game_arel.for_intermediate_type,
      ),
    )
  end
end
