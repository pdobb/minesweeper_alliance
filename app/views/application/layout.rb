# frozen_string_literal: true

# Application::Layout is a View Model for handling application-level view
# concerns.
#
# For example: It is a great alternative to having the ApplicationController
# define helper methods for use in controllers / view templates, such as the
# ubiquitous `current_user`.
class Application::Layout
  def initialize(context:)
    @context = context
  end

  def current_user = context.current_user

  def flash_notifications
    Application::Flash.new(flash).notifications
  end

  def theme_menu(button_content:)
    Application::Footer::ThemeMenu.new(button_content:)
  end

  def mobile?
    @mobile ||= UserAgent.parse(user_agent).mobile?
  end

  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def store_http_cookie(name, value:)
    cookies.permanent[name] = {
      value:,
      secure: App.production?,
      httponly: true,
    }
  end

  def cookies = context.__send__(:cookies)

  private

  attr_reader :context

  def request = context.request
  def flash = context.flash
  def user_agent = request.user_agent
end
