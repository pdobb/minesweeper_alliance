# frozen_string_literal: true

# App is utility module specific to this Rails Application and its environment.
module App
  def self.created_at = Time.zone.local(2024)

  def self.debug? = Rails.configuration.debug
  def self.dev_mode? = Rails.configuration.dev_mode
  def self.disable_turbo? = Rails.configuration.disable_turbo

  def self.test? = Rails.env.test?
  def self.development? = Rails.env.development?
  def self.production? = Rails.env.production?
end
