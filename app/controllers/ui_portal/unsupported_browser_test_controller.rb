# frozen_string_literal: true

class UIPortal::UnsupportedBrowserTestController < UIPortal::BaseController
  allow_browser(
    versions: {
      safari: false,
      chrome: false,
      firefox: false,
      opera: false,
      ie: false,
    },
    block: -> { redirect_to(unsupported_browser_path) },
  )

  def show; end
end
