# frozen_string_literal: true

# Games::New is a view model for displaying the Games New page.
class Games::New
  def presets
    Board::Settings::PRESETS.keys
  end

  def new_preset_game_url(preset, router = RailsRouter.instance)
    router.games_path(preset:)
  end

  def new_random_game_url(router = RailsRouter.instance)
    router.random_games_path
  end

  def new_custom_game_url(router = RailsRouter.instance)
    router.new_custom_game_path
  end
end
