# frozen_string_literal: true

# Application::Banner represents an Application-level banner / informational
# text. While this may banner *is* still dismissable, this dismissal is meant to
# last only until the next request.
#
# @see Application::PermanentlyDismissableBanner
class Application::Banner
  attr_reader :content

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

  # @param content [Hash]
  # @param context [#show_dismissal_button?] (Optional)
  #
  # @example Non-"Permanently"-Dismissable Banner
  #   Application::Banner.new(content: { text: "..." })
  def initialize(content:, context: nil)
    @content = content.fetch(:text)
    @context = context
  end

  def button_css = css.fetch(:button)

  # Whether or not the context (generally the object that instantiate this
  # object) wants the dismissal button to be shown.
  def show_dismissal_button?
    return true unless context

    context.show_banner_dismissal_button?
  end

  # UI Flag. Distinguishes this type of banner vs an
  # {Application::PermanentlyDismissableBanner}.
  def permanently_dismissable? = false

  private

  attr_reader :context

  def css = self.class.css
end
