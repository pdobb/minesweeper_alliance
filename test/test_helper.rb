# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["MT_NO_EXPECTATIONS"] = "true"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"

require "gemwork/test/support/much_stub-rails"
require "gemwork/test/support/reporters"
require "gemwork/test/support/spec_dsl"

require "support/assertions"
require "support/validation_error"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
  # order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
