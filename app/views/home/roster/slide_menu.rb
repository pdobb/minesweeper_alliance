# frozen_string_literal: true

# Home::Roster::SlideMenu represents the War Room Roster slide menu.
class Home::Roster::SlideMenu
  def self.css
    # rubocop:disable Layout/MultilineArrayLineBreaks
    @css ||= {
      menu: %w[
        absolute -top-12 right-0 z-10 text-right
        min-w-40 max-w-64
        border-l
      ],
      open_button: %w[
        absolute -top-8 right-2
        border-t border-r border-l border-dim rounded-t-md
        flex flex-row-reverse items-center gap-x-2
        -rotate-90 translate-x-8 translate-y-8
        text-dim-lg
      ],
      open_button_svg: %w[rotate-90],
      close_button: %w[
        absolute top-4 left-2
        border-t border-r border-b border-dim rounded-r-md
      ],
    }.with_indifferent_access.freeze
    # rubocop:enable Layout/MultilineArrayLineBreaks
  end

  def align = "right"

  def css
    self.class.css.fetch(:menu)
  end

  def open_button
    OpenButton.new
  end

  def close_button
    CloseButton.new
  end

  # HomeRoster::SlideMenu::OpenButton
  class OpenButton
    def direction = "left"

    def text = "ROSTER"

    def css
      self.class.module_parent.css.fetch(:open_button)
    end

    def svg_css
      self.class.module_parent.css.fetch(:open_button_svg)
    end
  end

  # HomeRoster::SlideMenu::CloseButton
  class CloseButton
    def direction = "right"

    def css
      self.class.module_parent.css.fetch(:close_button)
    end
  end
end
