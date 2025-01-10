# frozen_string_literal: true

# Notify is a Service Object used for notification of caught exceptions.
# Notification consists of:
# - Logging the exception details + a cleaned-up backtrace
# - Reraising the exception if applicable (based on the given `reraise` param)
# - Passing the exception on to any registered Services (e.g. Honeybadger)
#
# Note: Exceptions are not re-raised unless `Notify.configuration.reraise` is
# truthy. And this is really just meant for local development needs. Therefore,
# calling code should assume responsibility for re-raising caught exceptions if
# that is appropriate behavior for the context.
#
# @example Configuration
#   Notify.configure do |config|
#     config.reraise = Rails.configuration.x.notify.reraise
#     config.external_services << Notify::Services::Honeybadger
#   end
#
# @example Usage
#   Notify.(ex)
#   Notify.(ex, info: "...")
#   Notify.(ex, user: user.inspect)
#   Notify.(ex, user: user.inspect, alert: "...")
#   Notify.(ex, reraise: true)
#   Notify.(ex, logger: MyLogger.new)
class Notify
  include CallMethodBehaviors
  include ConfigurationBehaviors
  include ObjectInspector::InspectorsHelper

  def self.reraise? = !!config.reraise
  def self.external_services = config.external_services

  # @attr options [Hash]
  def initialize(
        exception,
        reraise: self.class.reraise?,
        logger: Rails.logger,
        **context)
    unless exception.is_a?(Exception)
      raise(TypeError, "Exception expected, got #{exception.class}")
    end

    @exception = exception
    @reraise = reraise
    @logger = logger
    @context = context
  end

  def call
    log
    reraise_if_applicable
    notify

    self
  end

  private

  attr_reader :exception,
              :logger,
              :context

  def log
    Log::Exception.(exception, message:, logger:)
  end

  def message
    context.presence&.to_s
  end

  def reraise_if_applicable
    debugger
    raise(exception) if reraise?
  end

  def reraise? = !!@reraise

  def notify
    self.class.external_services.each do |service|
      service.call(exception, context:)
    end
  end

  def inspect_identification
    identify(:exception)
  end

  # Notify::Services is a namespace for external notification service adapters.
  module Services # rubocop:disable Style/ClassAndModuleChildren
    # Notify::Services::Honeybadger is our current, preferred exceptions
    # aggregation service.
    #
    # @see https://app.honeybadger.io/projects
    class Honeybadger
      include CallMethodBehaviors

      def initialize(exception, context:)
        @exception = exception
        @service_options = { context: }
      end

      def self.available?
        defined?(::Honeybadger)
      end

      def call
        if exception
          notify_with_exception
        else
          notify_without_exception
        end
      end

      private

      attr_reader :exception,
                  :service_options

      def notify_with_exception
        ::Honeybadger.notify(exception, service_options)
      end

      def notify_without_exception
        ::Honeybadger.notify(
          service_options.dig(:context, :info),
          service_options)
      end
    end
  end

  # Notify::Configuration defines/holds the configuration settings for {Notify}
  # objects.
  class Configuration
    # :reek:Attribute
    attr_accessor :reraise,
                  :external_services

    def initialize
      @external_services = ServicesList.new
    end

    def to_h = { reraise:, external_services: }

    # Notify::Config::ServicesList allowing for building up a list of
    # `available?` notification services.
    class ServicesList < ::Array
      def <<(service)
        super if service.available?
      end
    end
  end
end
