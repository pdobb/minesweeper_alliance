# frozen_string_literal: true

class UIPortal::BaseController < ActionController::Base
  layout "application"

  helper_method :layout

  def layout
    @layout ||= Application::Layout.new(context: self)
  end
end
