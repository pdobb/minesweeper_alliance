# frozen_string_literal: true

# :reek:RepeatedConditional

# Games::Rules is a View Model for managing display of the game-play rules
# section.
class Games::Rules
  COOKIE_NAME = "rules"

  def initialize(context:)
    @context = context
  end

  def cookie_name = COOKIE_NAME

  def button_id = @button_id ||= "rules_button-#{Time.new.to_i}"
  def content_id = @content_id ||= "rules_content-#{Time.new.to_i}"

  def button_text = "Rules of Engagement"

  def button_css
    [
      "h4",
      "transition-colors",
      (collapsed_button_css if collapsed?),
    ].tap(&:compact!)
  end

  def collapsed_button_css = "text-dim-lg"

  def icon_css
    collapsed_icon_css if collapsed?
  end

  def collapsed_icon_css = "-rotate-90"

  def section_css
    [
      "space-y-10",
      (collapsed_section_css if collapsed?),
    ].tap(&:compact!)
  end

  def collapsed_section_css = "hidden"

  def open? = !collapsed?
  def collapsed? = cookies[cookie_name].present?

  private

  attr_reader :context

  def cookies = context.cookies
end
