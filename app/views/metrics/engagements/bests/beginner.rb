# frozen_string_literal: true

# Metrics::Engagements::Bests::Beginner represents {Game#type} = "Beginner" for
# presenting Metrics on the best engagements ({Game}s).
class Metrics::Engagements::Bests::Beginner
  include Metrics::Engagements::Bests::TypeBehaviors

  def type = Game::BEGINNER_TYPE

  private

  def arel = base_arel.for_beginner_type
end
