# frozen_string_literal: true

# Application::Banner represents Site-level banner text. i.e. informational text
# that, once dismissed, doesn't reappear in the future. Or, if permanent
# dismissal isn't desired, then we just won't be given a `name` parameter.
class Application::Banner
  attr_reader :content,
              :name

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
  # @example Non-"Permanently"-Dismissable Banner
  #   Application::Banner.new(content: { text: "..." })
  #
  # @example "Permanently"-Dismissable Banner
  #   Application::Banner.new(content: { text: "..." }, name: "welcome_banner"))
  def initialize(content:, name: nil)
    @content = content.fetch(:text)
    @name = name
  end

  def container_css_class
    Array.wrap(css_classes.fetch(:container))
  end

  def button_css_class
    Array.wrap(css_classes.fetch(:button))
  end

  def dismissable?
    name.present?
  end

  private

  def css_classes = self.class.css_classes
end
