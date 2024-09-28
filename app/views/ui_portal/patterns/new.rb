# frozen_string_literal: true

# UIPortal::Patterns::New is a View Model for servicing the
# UI Portal - Patterns - New page.
class UIPortal::Patterns::New
  def initialize(pattern = Pattern.new, context:)
    @pattern = pattern
    @context = context
  end

  def to_model = pattern
  def settings = pattern.settings

  def settings_form
    SettingsForm.new(settings, context:)
  end

  def any_errors? = pattern.errors.any?

  def display_errors
    pattern.errors.full_messages.join(", ")
  end

  private

  attr_reader :pattern,
              :context

  # UIPortal::Patterns::New::SettingsForm
  class SettingsForm
    STORAGE_KEY = :pattern_settings

    def initialize(pattern_settings, context:)
      @pattern_settings = pattern_settings
      @context = context
    end

    def value(name)
      current_value = pattern_settings.public_send(name)
      return current_value if any_errors?

      previous_settings[name] || current_value
    end

    def ranges(key)
      Pattern::Settings::RANGES.fetch(key)
    end

    def any_errors? = pattern_settings.errors.any?

    private

    attr_reader :pattern_settings,
                :context

    def previous_settings
      @previous_settings ||=
        JSON.parse(cookies[STORAGE_KEY] || "{}").with_indifferent_access
    end

    def cookies = context.cookies
  end
end
