# frozen_string_literal: true

# Games::New is a View Model for displaying the Games New page.
class Games::New
  def presets
    Board::Settings::PRESETS.keys
  end

  def game_url(preset)
    Router.games_path(preset:)
  end

  def random_game_url
    Router.random_game_path
  end

  def new_custom_game_url
    Router.new_custom_game_path
  end
end
