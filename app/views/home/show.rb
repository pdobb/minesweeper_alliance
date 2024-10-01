# frozen_string_literal: true

# Home::Show is a View Model for displaying the Home Page.
class Home::Show
  def initialize(current_game:)
    @current_game = current_game
  end

  def nav = Nav.new(current_game:)

  def welcome_banner(context:)
    WelcomeBanner.new(context:)
  end

  def current_game? = !!current_game

  def render_options
    if current_game?
      { partial: "games/game", locals: { view: current_game_show_view } }
    else # new_game?
      { partial: "games/new_container", locals: { view: new_view } }
    end
  end

  def game_just_ended?
    current_game.just_ended?
  end

  def game_stats_view
    Games::Stats.new(game: current_game)
  end

  private

  attr_reader :current_game

  def current_game_show_view
    Games::Show.new(game: current_game)
  end

  def new_view
    Games::New.new
  end

  def previous_game
    @previous_game ||= Game.second_to_last
  end

  # Home::Show::Nav is a View Model for handling navigation between Game - Show
  # pages.
  class Nav
    def initialize(current_game:)
      @current_game = current_game
    end

    def current_game? = !!current_game
    def previous_game? = !!previous_game

    def previous_game_url(router = RailsRouter.instance)
      router.game_path(previous_game)
    end

    def previous_game
      @previous_game ||= Game.second_to_last
    end

    private

    attr_reader :current_game
  end

  # Home::Show::WelcomeBanner is a View Model that aids in building a
  # {Application::PermanentlyDismissableBanner} based on the given context.
  class WelcomeBanner
    WELCOME_BANNER_NAME = "welcome_banner"
    BANNER_DISMISSAL_VALUE = "dismissed"

    def initialize(context:)
      @context = BannerContext.new(context:)
    end

    def show?
      context.cookies[WELCOME_BANNER_NAME] != BANNER_DISMISSAL_VALUE
    end

    def build_banner
      Application::PermanentlyDismissableBanner.new(
        name: WELCOME_BANNER_NAME,
        content: { text: },
        context:)
    end

    private

    attr_reader :context

    def text = I18n.t("site.description_html").html_safe

    # Home::Show::WelcomeBanner::BannerContext
    class BannerContext
      def initialize(context:)
        @base_context = context
      end

      def cookies(...) = @base_context.cookies(...)

      def show_banner_dismissal_button?
        @base_context.current_user_has_signed_their_name?
      end
    end
  end
end
