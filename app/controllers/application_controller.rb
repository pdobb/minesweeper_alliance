# frozen_string_literal: true

class ApplicationController < ActionController::Base
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
    if (time_zone = current_user.time_zone).present?
      Time.zone = time_zone
    end
  end
end
