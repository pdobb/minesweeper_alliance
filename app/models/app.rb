# frozen_string_literal: true

# App is utility module specific to this Rails Application and its environment.
module App
  def self.created_at = Time.zone.local(2024)

  # :reek:NilCheck
  def self.include_test_difficulty_level?
    if @include_test_difficulty_level.nil?
      @include_test_difficulty_level =
        test? || debug? || Game.for_difficulty_level_test.any?
    else
      @include_test_difficulty_level
    end
  end

  def self.debug? = Rails.configuration.debug

  def self.test? = Rails.env.test?
  def self.development? = Rails.env.development?
  def self.production? = Rails.env.production?
end
