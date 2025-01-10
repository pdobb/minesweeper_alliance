# frozen_string_literal: true

# Games::JustEnded::ParticipantFooter
class Games::JustEnded::ParticipantFooter < Games::JustEnded::Footer
  def self.turbo_stream_name = :just_ended_game

  def turbo_stream_name = self.class.turbo_stream_name

  def signature
    Games::Participants::Signature.new(game:, user:)
  end
end
