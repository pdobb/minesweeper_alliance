# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_time_zone

  helper_method :layout,
                :current_user

  def layout
    @layout ||= Application::Layout.new(context: self)
  end

  def current_user
    @current_user ||= CurrentUser.(context: layout)
  end

  private

  def set_time_zone
    time_zone = current_user.time_zone
    Time.zone = time_zone if time_zone.present?
  end
end
