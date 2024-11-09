# frozen_string_literal: true

# Metrics::Show is a View Model for displaying the Metrics Show page.
class Metrics::Show
  def engagements
    Engagements.new
  end

  # Metrics::Show::Engagements
  class Engagements
    def cache_key
      [:engagements, Game.for_status_alliance_wins.size]
    end

    def bests_per_type = Metrics::Engagements::Bests.per_type

    def display_case
      DisplayCase.new
    end

    # Metrics::Show::Engagements::DisplayCase
    class DisplayCase
      include Games::Past::DisplayCaseBehaviors
    end
  end
end
