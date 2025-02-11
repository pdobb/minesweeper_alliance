# frozen_string_literal: true

class DevPortal::ToggleDevCachingController < ApplicationController
  def create
    Rails::DevCaching.enable_by_file

    redirect_to(request.referer)
  end
end
