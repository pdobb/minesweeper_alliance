# frozen_string_literal: true

# Errors::UnsupportedBrowser represents the current browser version and lists
# supported, modern browser versions.
class Errors::UnsupportedBrowser
  def initialize(context:)
    @context = context
  end

  def browser_description
    "#{browser_name} #{browser_version}"
  end

  def modern_browser_versions_list
    [
      "Safari #{hash[:safari]}+",
      "Chrome #{hash[:chrome]}+",
      "Firefox #{hash[:firefox]}+",
      "Opera #{hash[:opera]}+",
    ]
  end

  private

  attr_reader :context

  def browser_name = context.browser_name
  def browser_version = context.browser_version

  def hash
    @hash ||=
      ActionController::AllowBrowser::BrowserBlocker::SETS.fetch(:modern)
  end
end
