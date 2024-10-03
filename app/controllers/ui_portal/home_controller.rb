# frozen_string_literal: true

class UIPortal::HomeController < UIPortal::BaseController
  def show
    @banner =
      Application::Banner.new(
        content: {
          text: I18n.t("site.description_html").html_safe,
        })
  end

  def flash_notifications
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
