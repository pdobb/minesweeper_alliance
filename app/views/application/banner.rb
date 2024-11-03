# frozen_string_literal: true

# Application::Banner represents an Application-level banner / informational
# text. While this may banner *is* still dismissable, this dismissal is meant to
# last only until the next request.
#
# @see Application::PermanentlyDismissableBanner
class Application::Banner
  attr_reader :content

  # @param content [Hash]
  # @param context [#show_dismissal_button?] (Optional)
  #
  # @example Non-"Permanently"-Dismissable Banner
  #   Application::Banner.new(content: { text: "..." })
  def initialize(content:, context: nil)
    @content = content.fetch(:text)
    @context = context
  end

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
end
