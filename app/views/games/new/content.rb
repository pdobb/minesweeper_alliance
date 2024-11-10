# frozen_string_literal: true

# Games::New::Content represents the content (buttons / form) for new {Game}s.
class Games::New::Content
  def self.turbo_frame_name = :new_game

  def turbo_frame_name = self.class.turbo_frame_name

  def presets
    Board::Settings::PRESETS.keys
  end

  def game_url(preset)
    Router.games_path(preset:)
  end

  def random_game_post_url
    Router.games_random_path
  end

  def new_custom_game_url
    Router.new_games_custom_path
  end
end
