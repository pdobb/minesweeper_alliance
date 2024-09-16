# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :layout

  def layout
    @layout ||= Application::Layout.new(context: self)
  end
end
