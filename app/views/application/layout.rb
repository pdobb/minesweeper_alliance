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

  def current_user
    @current_user ||= CurrentUser.(context: self)
  end

  def current_user?(user)
    current_user == user
  end

  def current_user_has_signed_their_name? = current_user.signer?
  def current_user_display_name = current_user.display_name
  def current_user_mms_id = current_user.mms_id

  def flash_notifications
    Application::Flash.new(flash).notifications
  end

  def theme_menu(button_content:)
    Application::ThemeMenu.new(button_content:)
  end

  def mobile?
    @mobile ||= UserAgent.parse(user_agent).mobile?
  end

  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def store_cookie(name, value:)
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
