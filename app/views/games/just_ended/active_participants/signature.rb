# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Signature represents the
# "Sign game?" / "Signed, <username>" (edit) link that shows for {User}s that
# actively participated in a just-ended {Game}.
class Games::JustEnded::ActiveParticipants::Signature
  def self.turbo_frame_name(user:) = [user, :signature]

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name = self.class.turbo_frame_name(user:)

  def attribution_prefix
    "Signed, " if user.signer?
  end

  def link_content
    user.signer? ? View.updateable_display_name(user:) : "Sign your username?"
  end

  def edit_url
    Router.edit_just_ended_game_current_user_path(game)
  end

  def signer? = user.signer?
  def not_a_signer? = user.not_a_signer?

  private

  attr_reader :game,
              :user
end
