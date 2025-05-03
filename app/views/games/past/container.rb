# frozen_string_literal: true

# Games::Past::Container represents the entire view context surrounding past
# {Game}s, as a partial for reuse.
class Games::Past::Container
  def self.display_case_turbo_frame_name = :past_game_display_case

  def initialize(game:)
    @game = game
  end

  def turbo_frame_name = self.class.display_case_turbo_frame_name

  # Dont cache recently-ended Games as they use a different display time format
  # (Elapsed Time: T+HH:MM:SS) vs older games (Time Range: HH:MM:SS–HH:MM:SS).
  def cacheable? = game_ended_over_a_day_ago?
  def cache_key = [:past_game_container, game, *game.users.pluck(:updated_at)]

  def content
    Games::Past::Content.new(game:)
  end

  def footer
    Games::Past::Footer.new(game:)
  end

  private

  attr_reader :game

  def game_ended_over_a_day_ago? = 1.day.ago >= game.ended_at
end
