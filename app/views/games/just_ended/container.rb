# frozen_string_literal: true

# Games::JustEnded::Container represents the entire view context surrounding
# {Game}s that have just ended.
class Games::JustEnded::Container
  def initialize(game:)
    @game = game
  end

  def partial_path
    "games/just_ended/container"
  end

  def content
    Games::JustEnded::Content.new(game:)
  end

  def footer_turbo_frame_name
    Games::JustEnded::Footer.turbo_frame_name(game)
  end

  def footer_source_url
    Router.just_ended_game_footer_path(game)
  end

  private

  attr_reader :game
end
