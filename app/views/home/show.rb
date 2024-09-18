# frozen_string_literal: true

# Home::Show is a view model for displaying the Home Page.
class Home::Show
  WELCOME_BANNER_NAME = "welcome_banner"
  BANNER_DISMISSAL_VALUE = "dismissed"

  def initialize(current_game:)
    @current_game = current_game
  end

  def show_welcome_banner?(context:)
    context.cookies[WELCOME_BANNER_NAME] != BANNER_DISMISSAL_VALUE
  end

  def welcome_banner
    Application::Banner.new(
      content: { text: I18n.t("site.description_html").html_safe },
      name: WELCOME_BANNER_NAME)
  end

  def current_game?
    !!current_game
  end

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
end
