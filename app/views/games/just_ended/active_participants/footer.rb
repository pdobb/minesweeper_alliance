# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Footer
class Games::JustEnded::ActiveParticipants::Footer
  def self.turbo_stream_name = :just_ended_game

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = Games::JustEnded::Footer.turbo_frame_name(game)
  def turbo_stream_name = self.class.turbo_stream_name

  def signature
    Games::JustEnded::ActiveParticipants::Signature.new(game:, user:)
  end

  def results
    Games::JustEnded::Results.new(game:)
  end

  private

  attr_reader :game,
              :user
end
