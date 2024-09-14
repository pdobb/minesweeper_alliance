# frozen_string_literal: true

# Layouts::Flash is a View Model that represents the Rails `flash`
# Notifications hash (ActionDispatch::Flash::FlashHash).
class Layouts::Flash
  TYPES = %i[alert notice info warning].freeze
  DEFAULT_TIMEOUT_IN_SECONDS = 10.seconds

  def initialize(collection)
    @collection = collection
  end

  def notifications
    collection.flat_map { |type, messages|
      notifications_for(type:, messages:)
    }
  end

  private

  attr_reader :collection

  def notifications_for(type:, messages:)
    Array(messages).map { |message|
      Notification.new(type:, message:)
    }
  end

  # Layouts::Flash::Notification wraps the actual Flash notification content.
  # Note: Flash notifications can be simple (just a String) or complex (a Hash).
  class Notification
    # rubocop:disable Layout/MultilineArrayLineBreaks
    CSS_CLASSES_MAP = {
      notice: {
        container: %w[bg-green-50 text-green-800 dark:text-green-400],
        button: %w[
          bg-green-50 hover:bg-green-200
          text-green-500 dark:text-green-400
          focus:ring-green-400
        ],
      },
      alert: {
        container: %w[bg-red-50 text-red-800 dark:text-red-400],
        button: %w[
          bg-red-50 hover:bg-red-200
          text-red-500 dark:text-red-400
          focus:ring-red-400
        ],
      },
      info: {
        container: %w[bg-blue-50 text-blue-800 dark:text-blue-400],
        button: %w[
          bg-blue-50 hover:bg-blue-200
          text-blue-500 dark:text-blue-400
          focus:ring-blue-400
        ],
      },
      warning: {
        container: %w[bg-yellow-50 text-yellow-800 dark:text-yellow-400],
        button: %w[
          bg-yellow-50 hover:bg-yellow-200
          text-yellow-500 dark:text-yellow-400
          focus:ring-yellow-400
        ],
      },
    }.with_indifferent_access.freeze
    # rubocop:enable Layout/MultilineArrayLineBreaks

    attr_reader :type,
                :message,
                :timeout

    # @param message [String, Hash]
    #
    # @example Message as a String
    #   Notification.new(type: :alert, message: "...")
    #
    # @example Message as a Hash
    #   Notification.new(type: :alert, message: { text: "..." })
    #   Notification.new(type: :alert, message: { text: "...", timeout: 3 })
    def initialize(type:, message:)
      @type = type

      if message.is_a?(Hash)
        @message = message.fetch(:text)
        @timeout = message.fetch(:timeout) { DEFAULT_TIMEOUT_IN_SECONDS }
      else
        @message = message
        @timeout = DEFAULT_TIMEOUT_IN_SECONDS
      end
    end

    def container_css_class
      CSS_CLASSES_MAP.fetch(type).fetch(:container)
    end

    def button_css_class
      CSS_CLASSES_MAP.fetch(type).fetch(:button)
    end

    def timeout_in_milliseconds
      return unless timeout?

      timeout.to_i * 1_000
    end

    def timeout?
      timeout.present?
    end
  end
end
