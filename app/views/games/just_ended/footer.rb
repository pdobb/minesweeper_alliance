# frozen_string_literal: true

# Games::JustEnded::Footer
class Games::JustEnded::Footer
  def self.turbo_frame_name(game) = [game, :just_ended_footer]

  def initialize(current_game:, user:)
    @current_game = current_game
    @user = user
  end

  def turbo_frame_name = self.class.turbo_frame_name(current_game)

  def signature
    Games::Users::Signature.new(game: current_game, user:)
  end

  def results
    Games::Past::Results.new(game: current_game)
  end

  private

  attr_reader :current_game,
              :user
end
