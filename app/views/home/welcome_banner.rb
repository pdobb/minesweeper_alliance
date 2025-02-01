# frozen_string_literal: true

# Home::WelcomeBanner aids in building
# {Application::PermanentlyDismissableBanner}s for the given context.
class Home::WelcomeBanner
  COOKIE = "welcome_banner"
  DISMISSED_VALUE = "dismissed"

  def self.show?(cookies) = cookies[COOKIE] != DISMISSED_VALUE
  def self.turbo_update_id = "welcomeBanner"

  def initialize(context:) = @context = context

  def turbo_update_id = self.class.turbo_update_id

  def show? = context.show_welcome_banner?

  def banner
    Application::PermanentlyDismissableBanner.new(
      cookie_name: COOKIE,
      content: { text: },
      context: PermanentlyDismissableBannerContext.new(context))
  end

  private

  attr_reader :context

  def text = I18n.t("site.description_html").html_safe

  # Home::WelcomeBanner::PermanentlyDismissableBannerContext services the needs
  # of {Application::PermanentlyDismissableBanner}.
  class PermanentlyDismissableBannerContext
    def initialize(context) = @context = context

    def show_banner_dismissal_button? = current_user.signer?
    def current_user = context.current_user

    private

    attr_reader :context
  end
end
