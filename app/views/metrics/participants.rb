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

  def most_active_per_type = Metrics::Participants::MostActive.per_type
end
