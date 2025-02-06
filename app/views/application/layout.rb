# frozen_string_literal: true

# Application::Layout is a View Model for handling application-level view
# concerns.
#
# For example: It is a great alternative to having {ApplicationController}
# define helper methods for use in controllers / view templates.
class Application::Layout
  def self.turbo_stream_name = "global"

  def initialize(context:)
    @context = context
  end

  def portal = "application".inquiry # rubocop:disable Rails/Inquiry
  def current_user = context.current_user
  def turbo_stream_name = self.class.turbo_stream_name
  def flash = Application::Flash.new(context.flash)

  def activity_indicator
    Games::Current::ActivityIndicator.new
  end

  def theme_menu(button_content:)
    Application::Footer::ThemeMenu.new(button_content:)
  end

  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def query_parameters = request.query_parameters

  def store_http_cookie(name, value:)
    cookies.permanent[name] = {
      value:,
      secure: App.production?,
      httponly: true,
    }
  end

  def store_signed_cookie(name, value:)
    cookies.signed.permanent[name] = {
      value:,
      secure: App.production?,
    }
  end

  def params = context.params
  def cookies = context.__send__(:cookies)
  def user_agent = request.user_agent

  def mobile? = parsed_user_agent.mobile?
  def browser_name = parsed_user_agent.browser
  def browser_version = parsed_user_agent.version

  private

  attr_reader :context

  def request = context.request

  def parsed_user_agent
    # UserAgent comes from the `useragent` gem:
    # https://github.com/gshutler/useragent
    @parsed_user_agent ||= UserAgent.parse(user_agent)
  end
end
