# frozen_string_literal: true

# :reek:RepeatedConditional

# Games::Current::Rules manages display of the game-play rules section (for the
# current {Game}).
class Games::Current::Rules
  COOKIE_NAME = "rules"

  def initialize(context)
    @context = Context.new(context)
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

  def reveal_method_descriptor
    mobile? ? "Tap" : "Click"
  end

  def reveal_neighbors_method_descriptor = reveal_method_descriptor

  def flag_method_descriptor
    mobile? ? "Long Press" : "Right Click"
  end

  private

  attr_reader :context

  def cookies = context.cookies
  def mobile? = context.mobile?

  # Games::Current::Rules::Context
  class Context
    def initialize(context)
      @context = context
    end

    def cookies = @context.cookies
    def mobile? = @context.mobile?
  end
end
