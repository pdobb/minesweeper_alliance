# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_user

  helper_method :current_user,
                :mobile?

  attr_reader :current_user

  def mobile?
    @mobile ||= UserAgent.parse(request.user_agent).mobile?
  end

  private

  def set_current_user
    @current_user = CurrentUser.(context: self)
  end
end
