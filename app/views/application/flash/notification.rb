# frozen_string_literal: true

# Application::Flash::Notification wraps the actual
# ActionDispatch::Flash::FlashHash content.
#
# Flash notifications can be simple (just a String) or complex (a Hash).
class Application::Flash::Notification
  DEFAULT_TIMEOUT_IN_SECONDS = 10.seconds

  attr_reader :type,
              :id,
              :content,
              :timeout

  def self.css_map
    # rubocop:disable Layout/MultilineArrayLineBreaks
    @css_map ||= {
      notice: {
        container: %w[
          bg-green-50 dark:bg-neutral-900
          text-green-800 dark:text-green-400
        ],
        button: %w[
          bg-green-50 dark:bg-neutral-900
          hover:bg-green-200 dark:hover:bg-neutral-800
          text-green-500 dark:text-green-400
          focus:ring-green-400 dark:focus:ring-green-400
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
          focus:ring-red-400 dark:focus:ring-red-400
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
          focus:ring-blue-400 dark:focus:ring-blue-400
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
          focus:ring-yellow-400 dark:focus:ring-yellow-400
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
  #   Notification.new(type: :info, content: { text: "...", timeout: false })
  def initialize(type:, content:)
    @type = type

    if content.is_a?(Hash)
      @content = content.fetch(:text)
      @timeout = content.fetch(:timeout) { DEFAULT_TIMEOUT_IN_SECONDS }
      @id = content[:id]
    else
      @content = content
      @timeout = DEFAULT_TIMEOUT_IN_SECONDS
    end
  end

  def container_css
    Array.wrap(css.fetch(:container))
  end

  def button_css
    Array.wrap(css.fetch(:button))
  end

  def timeout_in_milliseconds
    return unless timeout?

    timeout.to_i * 1_000
  end

  def timeout?
    timeout.present?
  end

  private

  def css
    self.class.css_map.fetch(type)
  end
end
