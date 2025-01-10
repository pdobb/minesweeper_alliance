# frozen_string_literal: true

# App is utility module specific to this Rails Application and its environment.
module App
  def self.created_at = Time.zone.local(2024)

  def self.debug? = Rails.configuration.debug
  def self.dev_mode? = Rails.configuration.dev_mode
  def self.disable_turbo? = Rails.configuration.disable_turbo

  def self.development? = Rails.env.development?
  def self.test? = Rails.env.test?
  def self.production_local? = Rails.env.production_local?
  def self.production? = Rails.env.production?

  def self.local? = Rails.env.local? || production_local?
end
