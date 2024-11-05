# frozen_string_literal: true

# Games::JustEnded::Show represents the entire view context surrounding {Game}s
# that have just ended.
class Games::JustEnded::Show
  def initialize(current_game:)
    @current_game = current_game
  end

  def template_path
    "games/just_ended/show"
  end

  def turbo_frame_name = Games::Current::Show.turbo_frame_name

  def content
    Games::JustEnded::Content.new(current_game:)
  end

  def footer(user:)
    Games::JustEnded::Footer.new(current_game:, user:)
  end

  private

  attr_reader :current_game
end
