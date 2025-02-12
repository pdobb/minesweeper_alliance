# frozen_string_literal: true

# Metrics::Participants::MostActive represents top-lists of the most active
# {User}s per each {Game#type} (Beginner, Intermediate, Expert).
module Metrics::Participants::MostActive
  def self.per_type
    [
      Beginner.new,
      Intermediate.new,
      Expert.new,
    ]
  end
end
