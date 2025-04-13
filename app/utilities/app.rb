# frozen_string_literal: true

# App is utility module specific to this Rails Application and its environment.
module App
  def self.introspect
    {
      name: I18n.t("site.name"),
      created_at:,
      env: Rails.env.to_s,
      debug_mode: debug?,
      interactions: Interaction.by_name.map(&:to_s),
      visits: Visit.by_path.map(&:to_s),
    }
  end

  def self.created_at = Time.zone.local(2024, 8, 9)

  def self.debug? = Rails.configuration.debug

  def self.test? = Rails.env.test?
  def self.development? = Rails.env.development?
  def self.production? = Rails.env.production?
end
