# frozen_string_literal: true

require "active_support/core_ext/integer/time"
require_relative "production"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/production.rb.

  # Show full error reports.
  config.consider_all_requests_local = true

  config.assume_ssl = false
  config.force_ssl = false

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.log_level = :debug
end
