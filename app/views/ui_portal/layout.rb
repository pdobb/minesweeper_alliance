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

  def flash_notifications
    Application::Flash.new(flash).notifications
  end

  def theme_menu(button_content:)
    Application::Footer::ThemeMenu.new(button_content:)
  end

  def cookies = context.__send__(:cookies)

  private

  attr_reader :context

  def flash = context.flash
end
