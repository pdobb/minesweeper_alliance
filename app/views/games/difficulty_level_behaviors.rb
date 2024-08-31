# frozen_string_literal: true

# Games::DifficultyLevelBehaviors defines common code needed by the
# Games::* View models for showing {::DificutlyLevel}-related info.
module Games::DifficultyLevelBehaviors
  extend ActiveSupport::Concern

  include WrapMethodBehaviors

  def name = to_model.name

  private

  def to_model = @difficulty_level
end
