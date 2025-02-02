# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::Signature represents the
# "Sign game?" / "Signed, <username>" (edit) link that shows for {User}s that
# actively participated in a just-ended {Game}.
class Games::JustEnded::ActiveParticipants::Signature
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def turbo_frame_name
    [user, :signature]
  end

  def attribution_prefix
    "Signed, " if user.signer?
  end

  def attribution_link_content
    base = user.signer? ? user.display_name : "Sign your name?"
    "#{base} #{Emoji.pencil}"
  end

  def attribution_link_url
    Router.edit_just_ended_game_current_user_path(game)
  end

  def signer? = user.signer?

  private

  attr_reader :game,
              :user
end
