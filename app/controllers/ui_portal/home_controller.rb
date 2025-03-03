# frozen_string_literal: true

class UIPortal::HomeController < UIPortal::BaseController
  def show
    @banner = Banner.new
  end

  # UIPortal::HomeController::Banner
  class Banner
    # :reek:UtilityFunction
    def text
      View.safe_join([
        I18n.t("site.welcome").html_safe,
        I18n.t("site.description_addendum_html").html_safe,
        I18n.t("site.learn_more_link_html").html_safe,
      ], " ")
    end
  end
end
