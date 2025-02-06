# frozen_string_literal: true

# UIPortal::Layout is a View Model for handling UIPortal-level view
# concerns.
#
# For example: It is a great alternative to having {UIPortal::BaseController}
# define helper methods for use in controllers / view templates.
class UIPortal::Layout
  def initialize(context:)
    @context = context
  end

  def portal = "ui".inquiry # rubocop:disable Rails/Inquiry
  def turbo_stream_name = Application::Layout.turbo_stream_name
  def flash = Application::Flash.new(context.flash)

  def theme_menu(button_content:)
    Application::Footer::ThemeMenu.new(button_content:)
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
