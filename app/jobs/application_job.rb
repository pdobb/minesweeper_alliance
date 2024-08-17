# frozen_string_literal: true

# ApplicationJob is the base model for all Active Job models in the app.
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock.
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer
  # available.
  # discard_on ActiveJob::DeserializationError
end
