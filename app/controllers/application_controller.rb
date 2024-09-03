# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :mobile?

  def mobile?
    @mobile ||= UserAgent.parse(request.user_agent).mobile?
  end
end
