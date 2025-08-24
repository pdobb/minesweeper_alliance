# frozen_string_literal: true

# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

################################################################################

Notify.configure do |config|
  config.reraise = Rails.configuration.x.notify.reraise
  config.external_services << Notify::Services::Honeybadger
end
