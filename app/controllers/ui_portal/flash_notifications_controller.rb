# frozen_string_literal: true

class UIPortal::FlashNotificationsController < UIPortal::BaseController
  def index
    now = l(Time.current, format: :debug)

    types = Application::Flash.notification_types
    types = types.sample(params[:count].to_i) if params.key?(:count)

    types.each do |type|
      flash.now[type] = [
        "Test #{type} #{now}",
        {
          text: "Test #{type} w/ no Auto-Timeout and w/ XL content. #{now}",
          timeout: false,
        },
      ]
    end
  end
end
