# frozen_string_literal: true

# Games::Past::Show represents the entire view context surrounding past {Game}s.
class Games::Past::Show
  def self.display_case_turbo_frame_name = :past_game_display_case

  def initialize(game:)
    @game = game
  end

  def turbo_frame_name = self.class.display_case_turbo_frame_name

  def cache_key(context:)
    [
      game,
      :past,
      context.mobile? ? :mobile : :web,
    ]
  end

  def content
    Games::Past::Content.new(game:)
  end

  def footer
    Games::Past::Footer.new(game:)
  end

  private

  attr_reader :game
end
