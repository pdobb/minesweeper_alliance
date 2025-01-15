# frozen_string_literal: true

# Home::Roster::SlideMenu represents the War Room Roster slide menu.
class Home::Roster::SlideMenu
  COOKIE_NAME = "war_room-roster"

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

  def initialize(context:)
    @context = Context.new(context)
  end

  def cookie_name = COOKIE_NAME

  def title = "Roster"

  def open_button
    OpenButton.new
  end

  def open? = !closed?
  def closed? = cookies[cookie_name].blank?

  def css = self.class.css.fetch(:menu)

  def close_button
    CloseButton.new
  end

  private

  attr_reader :context

  def cookies = context.cookies

  # Home::Roster::SlideMenu::Context
  class Context
    def initialize(context)
      @context = context
    end

    def cookies = @context.cookies
  end

  # Home::Roster::SlideMenu::OpenButton
  class OpenButton
    def direction = "left"
    def text = "ROSTER"
    def css = self.class.module_parent.css.fetch(:open_button)
    def svg_css = self.class.module_parent.css.fetch(:open_button_svg)
  end

  # Home::Roster::SlideMenu::CloseButton
  class CloseButton
    def direction = "right"
    def css = self.class.module_parent.css.fetch(:close_button)
  end
end
