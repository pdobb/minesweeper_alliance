# frozen_string_literal: true

# Router provides easy access to named routes from any context.
#
# @example
#   Router.root_path # => "/"
module Router
  class << self
    include Rails.application.routes.url_helpers
  end
end
