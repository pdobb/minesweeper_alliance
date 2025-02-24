# frozen_string_literal: true

# Games::JustEnded::ActiveParticipants::CurrentUser::Update aides "update"
# action/processing of the {User} "signature" form that shows at {Game} end for
# actively participating {User}s.
class Games::JustEnded::ActiveParticipants::CurrentUser::Update
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def signature
    Games::JustEnded::ActiveParticipants::Signature.new(game:, user:)
  end

  def signer_status_just_changed? = user.signer_status_just_changed?

  def nav
    CurrentUser::Nav.new(user:)
  end

  def welcome_banner_turbo_target
    Home::WelcomeBanner.turbo_target
  end

  def new_game_content
    Games::New::Content.new
  end

  private

  attr_reader :game,
              :user
end
