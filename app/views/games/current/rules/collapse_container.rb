# frozen_string_literal: true

# Games::Current::Rules::CollapseContainer
class Games::Current::Rules::CollapseContainer
  COOKIE = "rules"

  def initialize(context:)
    @context = Context.new(context)
  end

  def cookie_name = COOKIE

  def button_id = @button_id ||= "rules_button-#{Time.new.to_i}"
  def content_id = @content_id ||= "rules_content-#{Time.new.to_i}"

  def button_text = "Rules of Engagement"

  def button_css
    [
      %w[h4 transition-colors],
      { collapsed_button_css => collapsed? },
    ]
  end

  def collapsed_button_css = "text-dim-lg"

  def icon_css
    collapsed_icon_css if collapsed?
  end

  def collapsed_icon_css = "-rotate-90"

  def section_css
    [
      "space-y-10",
      { hidden: collapsed? },
    ]
  end

  def open? = !collapsed?
  def collapsed? = cookies[cookie_name].present?

  private

  attr_reader :context

  def cookies = context.cookies

  def collapsed_section_css = "hidden"

  # Games::Current::Rules::CollapseContainer::Context
  class Context
    def initialize(context) = @context = context
    def cookies = context.cookies

    private

    attr_reader :context
  end
end
