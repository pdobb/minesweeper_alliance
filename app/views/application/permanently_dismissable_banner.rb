# frozen_string_literal: true

# Application::PermanentlyDismissableBanner represents an Application-level
# banner / informational text. Once dismissed, this type of banner won't
# reappear in the future.
#
# @see Application::Banner
class Application::PermanentlyDismissableBanner
  attr_reader :name,
              :content

  def self.css
    # rubocop:disable Layout/MultilineArrayLineBreaks
    @css ||= {
      button: %w[
        hover:bg-gray-200 dark:hover:bg-neutral-700
        text-dim
        focus:ring-gray-400 hover:focus:bg-gray-200
      ],
    }.with_indifferent_access.freeze
    # rubocop:enable Layout/MultilineArrayLineBreaks
  end

  # @param name [String]
  # @param content [Hash]
  # @param context [#show_dismissal_button?]
  #
  # @example "Permanently"-Dismissable PermanentlyDismissableBanner
  #   Application::PermanentlyDismissableBanner.new(
  #     name: "welcome_banner",
  #     content: { text: "..." },
  #     context: layout))
  def initialize(name:, content:, context:)
    @content = content.fetch(:text)
    @name = name
    @context = context
  end

  def button_css = css.fetch(:button)

  # Whether or not the context (generally the object that instantiate this
  # object) wants the dismissal button to be shown.
  def show_dismissal_button? = context.show_banner_dismissal_button?

  # UI Flag. Distinguishes this type of banner vs an {Application::Banner}.
  def permanently_dismissable? = true

  private

  attr_reader :context

  def css = self.class.css
end
