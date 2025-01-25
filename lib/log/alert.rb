# frozen_string_literal: true

# Log::Alert aids in code-path debugging by logging a message along with a
# {BELL_EOMJI} (emoji/icon). The expectation, then, is that one will set up
# iTerm to trigger a "Ring Bell" and/or "Capture Output" action based on the
# presence of the {BELL_EMOJI} text.
#
# By default, Log::Alert will not run in the test environment.
#
# @example
#   Log::Alert.("Adding #{user.inspect} ... ")
#   # => 🔔 12:34:56 Adding User[123] ...
#
#   Log::Alert.("...", skip: -> { App.debug? })
#   # => nil
class Log::Alert
  BELL_EMOJI = "🔔"

  include CallMethodBehaviors

  def self.log_level = :info

  # :reek:ManualDispatch

  def initialize(message, logger: Rails.logger, skip: -> { App.test? })
    raise(TypeError, "skip must be callable") unless skip.respond_to?(:call)

    @message = message
    @logger = logger
    @skip = skip
  end

  def call
    return if skip?

    log_detailed_message
  end

  private

  attr_reader :message,
              :logger,
              :skip

  def skip? = skip&.call

  def log_detailed_message
    logger.public_send(log_level, detailed_message)
  end

  def log_level = self.class.log_level

  def detailed_message
    [
      BELL_EMOJI,
      timestamp,
      message,
    ].tap(&:compact!).join(" ")
  end

  def timestamp
    I18n.l(Time.current, format: :hours_minutes_seconds)
  end
end
