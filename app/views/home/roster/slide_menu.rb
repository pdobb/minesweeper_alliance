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
        border-t border-b border-l border-dim rounded-l-md
      ],
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

    def css
      self.class.module_parent.css.fetch(:open_button)
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
