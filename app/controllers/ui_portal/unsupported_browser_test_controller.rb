# frozen_string_literal: true

class UIPortal::UnsupportedBrowserTestController < UIPortal::BaseController
  allow_browser(
    versions: {
      safari: false,
      chrome: false,
      firefox: false,
      opera: false,
      ie: false,
    })

  def show
  end
end
