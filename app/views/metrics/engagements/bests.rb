# frozen_string_literal: true

# Metrics::Engagements::Bests represents top-lists of the best scoring {Game}s
# per each {Game#type} (Beginner, Intermediate, Expert).
module Metrics::Engagements::Bests
  def self.per_type
    [
      Beginner.new,
      Intermediate.new,
      Expert.new,
    ]
  end
end
