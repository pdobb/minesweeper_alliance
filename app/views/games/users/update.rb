# frozen_string_literal: true

# Games::Users::Update is a View Model for servicing the Update Action of the
# {User} "signature" form that shows at the end of a {Game}.
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

  def user_nav_turbo_frame_name
    [user, :nav]
  end

  def signer_status_just_changed? = user.signer_status_just_changed?

  def new_game_view
    Games::New.new
  end

  def welcome_banner(context:)
    Home::Show::WelcomeBanner.new(context:)
  end

  private

  attr_reader :game,
              :user
end
