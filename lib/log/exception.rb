# frozen_string_literal: true

# Log::Exception is a Service Object for logging an optional message + a
# detailed exception message/backtrace to the given logger (defaults to
# Rails.logger) with log level `error`. It will:
# - Log the passed-in `message`, if present
# - Log the exception details + backtrace for the passed-in `exception` (see:
#   {Log::Exception::Detail})
class Log::Exception
  include CallMethodBehaviors

  def self.log_level = :error

  def initialize(
        exception,
        message: nil,
        logger: Rails.logger,
        skip: -> { App.test? })
    raise(TypeError, "exception can't be nil") unless exception

    @exception = exception
    @message = message.presence
    @logger = logger
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
    Detail.(exception)
  end

  # Log::Exception::Detail outputs the given exception' message details + a
  # cleaned-up backtrace--via the passed-in `backtrace_cleaner` (default:
  # Rails.backtrace_cleaner).
  class Detail
    SEPARATOR = "\n - "

    include CallMethodBehaviors

    def initialize(exception, backtrace_cleaner: Rails.backtrace_cleaner)
      @exception = exception
      @backtrace_cleaner = backtrace_cleaner
    end

    def call
      [
        detailed_message,
        backtrace,
      ].join(SEPARATOR)
    end

    private

    def detailed_message = exception.detailed_message

    def backtrace
      backtrace_cleaner.clean(exception.backtrace).join(SEPARATOR)
    end

    attr_reader :exception,
                :backtrace_cleaner
  end
end
