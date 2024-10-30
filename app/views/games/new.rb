# frozen_string_literal: true

# Games::New is a View Model for displaying the Games New page.
class Games::New
  def presets
    Board::Settings::PRESETS.keys
  end

  def game_url(preset)
    router.games_path(preset:)
  end

  def random_game_url
    router.random_game_path
  end

  def new_custom_game_url
    router.new_custom_game_path
  end

  private

  def router = RailsRouter.instance
end
