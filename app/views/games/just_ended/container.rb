# frozen_string_literal: true

# Games::JustEnded::Container represents the entire view context surrounding
# {Game}s that have just ended, as a partial for reuse.
class Games::JustEnded::Container
  def initialize(current_game:)
    @current_game = current_game
  end

  def partial_path
    "games/just_ended/container"
  end

  def turbo_frame_name = Games::Current::Container.turbo_frame_name

  def content
    Games::JustEnded::Content.new(current_game:)
  end

  def footer(user:)
    Games::JustEnded::Footer.new(current_game:, user:)
  end

  private

  attr_reader :current_game
end
