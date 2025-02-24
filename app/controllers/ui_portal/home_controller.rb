# frozen_string_literal: true

class UIPortal::HomeController < UIPortal::BaseController
  def show
    @banner = Application::Banner.new(text:)
  end

  private

  def text = I18n.t("site.description_html").html_safe
end
