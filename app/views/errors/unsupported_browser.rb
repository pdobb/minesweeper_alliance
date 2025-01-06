# frozen_string_literal: true

# Errors::UnsupportedBrowser represents the current browser version and lists
# supported, modern browser versions.
class Errors::UnsupportedBrowser
  def initialize(context:)
    @context = context
  end

  def current_browser_version
    "#{user_agent.browser} #{user_agent.version}"
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

  def user_agent = context.user_agent

  def hash
    @hash ||=
      ActionController::AllowBrowser::BrowserBlocker::SETS.fetch(:modern)
  end
end
