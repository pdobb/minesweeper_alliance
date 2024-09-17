# frozen_string_literal: true

# Application::Banner represents Site-level banner text. i.e. informational text
# that, once dismissed, doesn't reappear in the future.
class Application::Banner
  attr_reader :content

  def self.css_classes
    # rubocop:disable Layout/MultilineArrayLineBreaks
    @css_classes ||= {
      container: nil,
      button: %w[
        hover:bg-gray-200 dark:hover:bg-neutral-700
        text-gray-500 dark:text-gray-400
        focus:ring-gray-400 hover:focus:bg-gray-200
      ],
    }.with_indifferent_access.freeze
    # rubocop:enable Layout/MultilineArrayLineBreaks
  end

  # @param content [Hash]
  #
  # @example
  #   Application::Banner.new(content: { text: "..." })
  def initialize(content:)
    @content = content.fetch(:text)
  end

  def container_css_class
    Array.wrap(css_classes.fetch(:container))
  end

  def button_css_class
    Array.wrap(css_classes.fetch(:button))
  end

  private

  def css_classes = self.class.css_classes
end
