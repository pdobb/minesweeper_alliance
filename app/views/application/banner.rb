# frozen_string_literal: true

# Application::Banner represents a site banner / informational text.
class Application::Banner
  attr_reader :content

  def initialize(text:)
    @content = text
  end

  private

  attr_reader :context
end
