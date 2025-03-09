# frozen_string_literal: true

# Metrics::Participants::MostActive::Beginner represents
# {Game#type} = "Beginner" for presenting Metrics on the most active {User}s.
class Metrics::Participants::MostActive::Beginner
  include Metrics::Participants::MostActive::TypeBehaviors

  def type = Game::BEGINNER_TYPE

  private

  def arel
    base_arel.merge(
      ParticipantTransaction.joins(:game).merge(
        base_game_arel.for_beginner_type))
  end
end
