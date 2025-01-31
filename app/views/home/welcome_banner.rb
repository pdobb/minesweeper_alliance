# frozen_string_literal: true

# Home::WelcomeBanner aids in building
# {Application::PermanentlyDismissableBanner}s for the given context.
class Home::WelcomeBanner
  COOKIE = "welcome_banner"
  DISMISSED_VALUE = "dismissed"

  def self.turbo_frame_name = :welcome_banner

  def initialize(context:)
    @context = BannerContext.new(context)
  end

  def turbo_frame_name = self.class.turbo_frame_name

  def show?
    context.cookies[COOKIE] != DISMISSED_VALUE
  end

  def banner
    Application::PermanentlyDismissableBanner.new(
      cookie_name: COOKIE,
      content: { text: },
      context:)
  end

  private

  attr_reader :context

  def text = I18n.t("site.description_html").html_safe

  # Home::WelcomeBanner::BannerContext
  class BannerContext
    def initialize(context) = @context = context

    def cookies(...) = context.cookies(...)
    def show_banner_dismissal_button? = current_user.active_participant?
    def current_user = context.current_user

    private

    attr_reader :context
  end
end
