# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_time_zone

  helper_method :layout

  def layout
    @layout ||= Application::Layout.new(context: self)
  end

  private

  def set_time_zone
    Time.zone = time_zone if time_zone.present?
  end

  def time_zone = layout.current_user_time_zone
end
