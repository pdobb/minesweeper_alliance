# frozen_string_literal: true

Rails.application.configure do
  config.exceptions_app = routes
  config.action_dispatch.show_exceptions = :all
end
