# frozen_string_literal: true

# Application::Flash is a View Model that represents the Rails `flash`
# Notifications hash (ActionDispatch::Flash::FlashHash).
#
# Note: We only pay attention to known {.notification_types}. This allows the
# ActionDispatch::Flash::FlashHash to be used for other purposes as well.
class Application::Flash
  DEFAULT_TIMEOUT_IN_SECONDS = 10.seconds

  def self.notification_types
    @notification_types ||= %w[alert notice info warning].freeze
  end

  def initialize(collection)
    @collection = collection
  end

  def notifications
    collection.flat_map { |type, content|
      next if self.class.notification_types.exclude?(type)

      notifications_for(type:, content:)
    }.tap(&:compact!)
  end

  private

  attr_reader :collection

  def notifications_for(type:, content:)
    Array(content).map { |the_content|
      Notification.new(type:, content: the_content)
    }
  end

  # Application::Flash::Notification wraps the actual Flash notification
  # content.
  #
  # Flash notifications can be simple (just a String) or complex (a Hash).
  class Notification
    attr_reader :type,
                :content,
                :timeout

    def self.css_classes_map
      # rubocop:disable Layout/MultilineArrayLineBreaks
      @css_classes_map ||= {
        notice: {
          container: %w[
            bg-green-50 dark:bg-neutral-900
            text-green-800 dark:text-green-400
          ],
          button: %w[
            bg-green-50 dark:bg-neutral-900
            hover:bg-green-200 dark:hover:bg-neutral-800
            text-green-500 dark:text-green-400
            focus:ring-green-400 hover:focus:bg-green-200
          ],
        },
        alert: {
          container: %w[
            bg-red-50 dark:bg-neutral-900
            text-red-800 dark:text-red-400
          ],
          button: %w[
            bg-red-50 dark:bg-neutral-900
            hover:bg-red-200 dark:hover:bg-neutral-800
            text-red-500 dark:text-red-400
            focus:ring-red-400 hover:focus:bg-red-200
          ],
        },
        info: {
          container: %w[
            bg-blue-50 dark:bg-neutral-900
            text-blue-800 dark:text-blue-400
          ],
          button: %w[
            bg-blue-50 dark:bg-neutral-900
            hover:bg-blue-200 dark:hover:bg-neutral-800
            text-blue-500 dark:text-blue-400
            focus:ring-blue-400 hover:focus:bg-blue-200
          ],
        },
        warning: {
          container: %w[
            bg-yellow-50 dark:bg-neutral-900
            text-yellow-800 dark:text-yellow-400
          ],
          button: %w[
            bg-yellow-50 dark:bg-neutral-900
            hover:bg-yellow-200 dark:hover:bg-neutral-800
            text-yellow-500 dark:text-yellow-400
            focus:ring-yellow-400 hover:focus:bg-yellow-200
          ],
        },
      }.with_indifferent_access.freeze
      # rubocop:enable Layout/MultilineArrayLineBreaks
    end

    # @param type [Symbol]
    # @param content [String, Hash]
    #
    # @example Notification as a String
    #   Notification.new(type: :alert, content: "...")
    #
    # @example Notification as a Hash
    #   Notification.new(type: :info, content: { text: "..." })
    #   Notification.new(type: :info, content: { text: "...", timeout: 3 })
    def initialize(type:, content:)
      @type = type

      if content.is_a?(Hash)
        @content = content.fetch(:text)
        @timeout = content.fetch(:timeout) { DEFAULT_TIMEOUT_IN_SECONDS }
      else
        @content = content
        @timeout = DEFAULT_TIMEOUT_IN_SECONDS
      end
    end

    def container_css_class
      Array.wrap(css_classes.fetch(:container))
    end

    def button_css_class
      Array.wrap(css_classes.fetch(:button))
    end

    def timeout_in_milliseconds
      return unless timeout?

      timeout.to_i * 1_000
    end

    def timeout?
      timeout.present?
    end

    private

    def css_classes
      self.class.css_classes_map.fetch(type)
    end
  end
end
