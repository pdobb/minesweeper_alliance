# frozen_string_literal: true

# Games::Current::Container represents the entire view context surrounding the
# current {Game}, as a partial for reuse.
class Games::Current::Container
  def self.turbo_frame_name = :current_game_container

  def initialize(game:)
    @game = game
  end

  def partial_path
    "games/current/container"
  end

  def turbo_frame_name = self.class.turbo_frame_name

  def status
    Games::Current::Status.new(game:)
  end

  def content
    Games::Current::Content.new(game:)
  end

  def footer
    Games::Current::Footer.new
  end

  private

  attr_reader :game
end
