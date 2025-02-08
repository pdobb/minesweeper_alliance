# frozen_string_literal: true

# Metrics::Participants
class Metrics::Participants
  def cache_key
    [
      :metrics,
      :participants,
      Game.count,
    ]
  end

  def most_actives_per_type = Metrics::Participants::MostActives.per_type
end
