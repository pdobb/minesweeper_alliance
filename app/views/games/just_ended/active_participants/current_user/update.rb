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

  def duty_roster_listing
    Games::JustEnded::ActiveParticipants::Roster::Listing.new(user, game:)
  end

  def user_nav
    Application::UserNav.new(current_user: user)
  end

  def signer_status_just_changed? = user.signer_status_just_changed?

  def welcome_banner(context:)
    Home::WelcomeBanner.new(context:)
  end

  def new_game_content
    Games::New::Content.new
  end

  private

  attr_reader :game,
              :user
end
