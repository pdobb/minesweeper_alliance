# frozen_string_literal: true

# :reek:TooManyInstanceVariables

# Log::Exception is a Service Object for logging an optional message + a
# detailed exception message/backtrace to the given logger (defaults to
# Rails.logger) with log level `error`. It will:
# - Log the passed-in `message`, if present
# - Log the exception details + backtrace for the passed-in `exception` (see:
#   {Log::Exception::Detail})
#
# @example
#   Log::Exception.(ex)
#   Log::Exception.(ex, message: "Oh, no! The thing happened!")
#   Log::Exception.(ex, backtrace_cleaner: Rails.backtrace_cleaner)
class Log::Exception
  def self.call(...) = new(...).call

  def self.log_level = :error

  def initialize(
    exception,
    message: nil,
    logger: Rails.logger,
    backtrace_cleaner: nil,
    skip: -> { App.test? }
  )
    raise(TypeError, "exception can't be nil") unless exception

    @exception = exception
    @message = message.presence
    @logger = logger
    @backtrace_cleaner = backtrace_cleaner
    @skip = skip
  end

  def call
    return if skip?

    log_detailed_message
  end

  private

  attr_reader :exception,
              :message,
              :logger,
              :skip

  def skip? = skip.call

  def log_detailed_message
    logger.public_send(log_level, detailed_message)
  end

  def log_level = self.class.log_level

  def detailed_message
    [
      message,
      exception_details,
    ].tap(&:compact!).join("\n")
  end

  def exception_details
    Detail.(exception, backtrace_cleaner:)
  end

  def backtrace_cleaner = @backtrace_cleaner || NullBacktraceCleaner

  # Log::Exception::Detail outputs the given exception' message details + a
  # cleaned-up backtrace--via the passed-in `backtrace_cleaner` (default:
  # Rails.backtrace_cleaner).
  class Detail
    SEPARATOR = "\n - "

    def self.call(...) = new(...).call

    def initialize(exception, backtrace_cleaner:)
      @exception = exception
      @backtrace_cleaner = backtrace_cleaner
    end

    def call
      [
        detailed_message,
        *backtrace,
      ].join(SEPARATOR)
    end

    private

    def detailed_message = exception.detailed_message

    def backtrace
      backtrace_cleaner.clean(exception.backtrace)
    end

    attr_reader :exception,
                :backtrace_cleaner
  end

  # Log::Exception::NullBacktraceCleaner is a simple pass-through / stand-in for
  # an actual "backtrace cleaner" (such as Rails.backtrace_cleaner).
  module NullBacktraceCleaner
    def self.clean(array) = array
  end
end
