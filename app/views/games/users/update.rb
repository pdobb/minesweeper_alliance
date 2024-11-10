# frozen_string_literal: true

# Games::Users::Update aides "update" action/processing of the {User}
# "signature" form that shows at {Game} end.
class Games::Users::Update
  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def signature
    Games::Users::Signature.new(game:, user:)
  end

  def duty_roster_listing
    Games::Users::DutyRoster::Listing.new(user, game:)
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
