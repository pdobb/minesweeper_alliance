# frozen_string_literal: true

# AllowBrowserBehaviors is a mix-in for including the `allow_browser` macro
# with our standard configuration.
#
# See: https://api.rubyonrails.org/classes/ActionController/AllowBrowser/ClassMethods.html#method-i-allow_browser
module AllowBrowserBehaviors
  extend ActiveSupport::Concern

  included do
    # Only allow modern browsers supporting webp images, web push, badges,
    # import maps, CSS nesting, and CSS :has.
    allow_browser(
      versions: :modern,
      block: -> { redirect_to(unsupported_browser_path) }, # Custom Error Page
      unless: -> {
        request.user_agent&.match?(
          /Twitterbot|facebookexternalhit|Googlebot|Pinterestbot|redditbot/i,
        )
      },
    )
  end
end
