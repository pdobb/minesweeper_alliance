# frozen_string_literal: true

# App is utility module specific to this Rails Application and its environment.
module App
  def self.exclude_test_difficulty_level?
    @exclude_test_difficulty_level ||=
      !debug? && Game.for_difficulty_level_test.none?
  end

  def self.debug? = Rails.configuration.debug
end
