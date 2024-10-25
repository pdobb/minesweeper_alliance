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

  def button_css_class
    [
      "h4",
      "transition-colors",
      (collapsed_button_css_class if collapsed?),
    ].tap(&:compact!)
  end

  def collapsed_button_css_class = "text-gray-500"

  def icon_css_class
    collapsed_icon_css_class if collapsed?
  end

  def collapsed_icon_css_class = "-rotate-90"

  def section_css_class
    [
      "space-y-10",
      (collapsed_section_css_class if collapsed?),
    ].tap(&:compact!)
  end

  def collapsed_section_css_class = "hidden"

  def open? = !collapsed?
  def collapsed? = cookies[cookie_name].present?

  private

  attr_reader :context

  def cookies = context.cookies
end
