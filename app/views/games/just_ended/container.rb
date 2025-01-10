# frozen_string_literal: true

# Games::JustEnded::Container represents the entire view context surrounding
# {Game}s that have just ended.
class Games::JustEnded::Container
  def initialize(current_game:)
    @current_game = current_game
  end

  def turbo_frame_name = Games::Current::Container.turbo_frame_name

  def version = current_game.version

  def content
    Games::JustEnded::Content.new(current_game:)
  end

  def footer_turbo_frame_name
    Games::JustEnded::Footer.turbo_frame_name(current_game)
  end

  def footer_source_url
    Router.game_just_ended_footer_path(current_game)
  end

  private

  attr_reader :current_game
end
