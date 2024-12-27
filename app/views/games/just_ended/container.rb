# frozen_string_literal: true

# Games::JustEnded::Container represents the entire view context surrounding
# {Game}s that have just ended, as a partial for reuse.
class Games::JustEnded::Container
  def self.turbo_stream_name = :just_ended_game

  def initialize(current_game:)
    @current_game = current_game
  end

  def turbo_stream_name = self.class.turbo_stream_name

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
