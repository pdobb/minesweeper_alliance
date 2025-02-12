# frozen_string_literal: true

class DevPortal::BaseController < ActionController::Base
  layout "application"

  helper_method :layout

  def layout
    @layout ||= DevPortal::Layout.new(context: self)
  end
end
