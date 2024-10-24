# frozen_string_literal: true

# RailsRouter is a Singleton object that provides access to Rails' URL helpers
# and path/URL generation behaviors, on demand.
#
# @example
#   def game_url(router = RailsRouter.instance)
#     router.game_path(to_model)
#   end
class RailsRouter
  include Singleton
  include Rails.application.routes.url_helpers
end
