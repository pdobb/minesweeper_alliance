# frozen_string_literal: true

# Home::WelcomeBanner is an {Application::Banner} that is shown based on the
# given {#context}.
class Home::WelcomeBanner
  def self.turbo_target = "welcomeBanner"

  def initialize(context:)
    @context = context
  end

  def turbo_target = self.class.turbo_target

  def show? = context.show_welcome_banner?

  def banner
    Application::Banner.new(text:)
  end

  private

  attr_reader :context

  def text = I18n.t("site.description_html").html_safe
end
