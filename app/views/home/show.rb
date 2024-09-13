# frozen_string_literal: true

# Home::Show is a view model for displaying the Home Page.
class Home::Show
  def initialize(current_game:)
    @current_game = current_game
  end

  def current_game?
    !!current_game
  end

  def render_options
    if current_game?
      { partial: "games/game", locals: { view: current_game_show_view } }
    else # new_game?
      { partial: "games/new", locals: { view: new_view } }
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
