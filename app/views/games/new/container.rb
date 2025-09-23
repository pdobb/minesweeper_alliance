# frozen_string_literal: true

# Games::New::Container represents the entire view context surrounding new
# {Game}s, as a partial for reuse.
class Games::New::Container
  TITLE_CACHE_EXPIRES_DURATION = 30.seconds
  private_constant :TITLE_CACHE_EXPIRES_DURATION

  def partial_path
    "games/new/container"
  end

  def title_cache_key = :new_game_title
  def title_cahce_expires_in = TITLE_CACHE_EXPIRES_DURATION

  def title = I18n.t("game.new_html").sample

  def content
    Games::New::Content.new
  end
end
