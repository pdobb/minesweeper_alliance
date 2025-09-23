# frozen_string_literal: true

# Games::Current::Rules::CollapseContainer
class Games::Current::Rules::CollapseContainer
  COOKIE = "rules"
  public_constant :COOKIE

  def initialize(context:)
    @context = context
  end

  def cookie_store? = true
  def cookie_name = COOKIE

  def record_interaction? = true
  def interaction_data = "Toggle Rules of Engagement"

  def open? = !collapsed?
  def collapsed? = cookies[cookie_name].present?

  def button_id = "rules_button-#{unique_id}"
  def button_text = "Rules of Engagement"
  def button_css = "h4"

  def content_id = "rules_content-#{unique_id}"
  def content_css = "space-y-10"

  private

  attr_reader :context

  def cookies = context.cookies

  def unique_id = @unique_id ||= Time.new.to_i
end
