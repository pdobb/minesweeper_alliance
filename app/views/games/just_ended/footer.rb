# frozen_string_literal: true

# Games::JustEnded::Footer
class Games::JustEnded::Footer
  def self.turbo_frame_name(game) = [game, :just_ended_footer]

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = self.class.turbo_frame_name(game)

  def results
    Games::JustEnded::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
