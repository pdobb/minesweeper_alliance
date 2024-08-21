# frozen_string_literal: true

# Opt out of Google Chrome's FLoC User Tracking.
# See:
# - https://andycroll.com/ruby/opt-out-of-google-floc-tracking-in-rails/
# - https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Permissions-Policy
# - https://web.dev/articles/floc
Rails.application.config.action_dispatch.default_headers["Permissions-Policy"] =
  "interest-cohort=()"
