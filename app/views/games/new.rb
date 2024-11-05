# frozen_string_literal: true

# Games::New is a View Model for displaying the New {Game} view.
class Games::New
  def self.turbo_frame_name = :new_game

  def template_path
    "games/new"
  end

  def turbo_frame_name = self.class.turbo_frame_name

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
