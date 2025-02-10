# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Footer
class Games::JustEnded::ActiveParticipants::Footer
  def self.turbo_stream_name = "just_ended_game-active_participants"

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def to_param = self.class.turbo_stream_name
  def turbo_frame_name = Games::JustEnded::Footer.turbo_frame_name(game)

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
