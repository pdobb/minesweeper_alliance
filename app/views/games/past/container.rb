# frozen_string_literal: true

# Games::Past::Container represents the entire view context surrounding past
# {Game}s, as a partial for reuse.
class Games::Past::Container
  def self.display_case_turbo_frame_name = :past_game_display_case

  def initialize(game:)
    @game = game
  end

  def turbo_frame_name = self.class.display_case_turbo_frame_name
  def cache_key = [game, :past]

  def content
    Games::Past::Content.new(game:)
  end

  def footer
    Games::Past::Footer.new(game:)
  end

  private

  attr_reader :game
end
