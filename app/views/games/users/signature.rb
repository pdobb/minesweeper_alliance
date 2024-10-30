# frozen_string_literal: true

# Games::Users::Signature is a View Model for servicing the "Sign game?" /
# "Signed, <username>" (edit) link that shows for participating {User}s at the
# end of a {Game} (and on the Games - Show page).
#
# @see Games::Results
class Games::Users::Signature
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def show?
    game.recently_ended? && user.participated_in?(game)
  end

  def turbo_frame_name
    [game, :signature]
  end

  def attribution_prefix
    "Signed, " if user.signer?
  end

  def attribution_link_content
    base = user.signer? ? user.display_name : "Sign your name?"
    "#{base} #{Emoji.pencil}"
  end

  def attribution_link_url
    router.edit_game_user_path(game)
  end

  private

  attr_reader :game,
              :user

  def router = RailsRouter.instance
end
