# frozen_string_literal: true

class UIPortal::BaseController < ActionController::Base
  layout "application"

  helper_method :layout

  def layout
    @layout ||= UIPortal::Layout.new(context: self)
  end
end
