# frozen_string_literal: true

# Home::WelcomeBanner represents a "Site Welcome" banner/text that is shown
# based on the given {#context}.
class Home::WelcomeBanner
  def self.turbo_target = "welcomeBanner"

  def initialize(context:)
    @context = context
  end

  def turbo_target = self.class.turbo_target

  def show? = context.show_welcome_banner?

  def text
    View.safe_join([
      I18n.t("site.welcome").html_safe,
      I18n.t("site.learn_more_link_html").html_safe,
    ], " ")
  end

  private

  attr_reader :context
end
