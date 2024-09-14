# frozen_string_literal: true

# ThemeMenu is a View Model for rendering the "Theme" menu for choosing the
# Light/Dark/System themes. This abstraction exists just to service the
# application/_menu.html.erb partial with the unique values that it needs.
class ThemeMenu
  attr_reader :button_content

  def initialize(button_content:)
    @button_content = button_content
  end

  def render_options
    { layout: "application/menu", locals: { view: self } }
  end

  def title
    "Theme"
  end

  def button_attributes
    { data: { theme_target: "themeSelectorButton" } }
  end

  def button_css
    "btn-basic"
  end

  def menu_css
    # rubocop:disable Layout/MultilineArrayLineBreaks
    %w[
      mb-3 w-36
      right-0 bottom-full origin-bottom-right
    ]
    # rubocop:enable Layout/MultilineArrayLineBreaks
  end

  def menu_attributes
    {}
  end
end
