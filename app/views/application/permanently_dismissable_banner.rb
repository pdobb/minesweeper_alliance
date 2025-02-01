# frozen_string_literal: true

# Application::PermanentlyDismissableBanner represents an Application-level
# banner / informational text. Once dismissed, this type of banner won't
# reappear in the future.
#
# @see Application::Banner
class Application::PermanentlyDismissableBanner
  attr_reader :cookie_name,
              :content

  def self.css
    # rubocop:disable Layout/MultilineArrayLineBreaks
    @css ||= {
      button: %w[
        hover:bg-gray-200 dark:hover:bg-neutral-700
        focus:ring-2 focus:ring-gray-400 focus:animate-pulse-fast
        text-dim
      ],
    }.with_indifferent_access.freeze
    # rubocop:enable Layout/MultilineArrayLineBreaks
  end

  # @param cookie_name [String]
  # @param content [Hash]
  # @param context [#show_dismissal_button?]
  #
  # @example "Permanently"-Dismissable PermanentlyDismissableBanner
  #   Application::PermanentlyDismissableBanner.new(
  #     cookie_name: "welcome_banner",
  #     content: { text: "..." },
  #     context: [...]PermanentlyDismissableBannerContext.new(layout)))
  def initialize(cookie_name:, content:, context:)
    @content = content.fetch(:text)
    @cookie_name = cookie_name
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
