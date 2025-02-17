# frozen_string_literal: true

# Metrics::Engagements::Bests::Expert represents {Game#type} = "Expert" for
# presenting Metrics on the best engagements ({Game}s).
class Metrics::Engagements::Bests::Expert
  include Metrics::Engagements::Bests::TypeBehaviors

  def type = Game::EXPERT_TYPE

  private

  def arel = base_arel.for_expert_type
end
