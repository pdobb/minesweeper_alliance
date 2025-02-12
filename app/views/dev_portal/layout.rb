# frozen_string_literal: true

# DevPortal::Layout is a View Model for handling DevPortal-level view
# concerns.
#
# For example: It is a great alternative to having {DevPortal::BaseController}
# define helper methods for use in controllers / view templates.
class DevPortal::Layout
  def initialize(context:)
    @context = context
  end

  def portal = "dev".inquiry # rubocop:disable Rails/Inquiry
  def to_param = Application::Layout.turbo_stream_name
  def flash = Application::Flash.new(context.flash)

  def theme_menu(button_content:)
    Application::Footer::ThemeMenu.new(button_content:)
  end

  def store_http_cookie(name, value:)
    cookies.permanent[name] = { value:, httponly: true }
  end

  def cookies = context.__send__(:cookies)

  def mobile? = parsed_user_agent.mobile?

  private

  attr_reader :context

  def parsed_user_agent
    # UserAgent comes from the `useragent` gem:
    # https://github.com/gshutler/useragent
    @parsed_user_agent ||= UserAgent.parse(user_agent)
  end

  def user_agent = request.user_agent
  def request = context.request
end
