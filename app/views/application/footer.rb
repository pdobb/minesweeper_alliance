# frozen_string_literal: true

class Application::Footer # rubocop:disable Style/ClassAndModuleChildren
  # Application::Footer::ThemeMenu is a View Model for rendering the "Theme"
  # menu for choosing the Light/Dark/System themes. This abstraction exists just
  # to service the application/_menu.html.erb partial with the unique values
  # that it needs.
  class ThemeMenu
    attr_reader :button_content

    def initialize(button_content:)
      @button_content = button_content
    end

    def title = "Theme"

    def button_attributes
      { data: { theme_target: "themeSelectorButton" } }
    end

    def button_css
      "btn-basic"
    end

    def menu_attributes
      {}
    end

    def menu_css
      # rubocop:disable Layout/MultilineArrayLineBreaks
      %w[
        right-0 bottom-full origin-bottom-right
        mb-3 w-32
      ]
      # rubocop:enable Layout/MultilineArrayLineBreaks
    end
  end
end
