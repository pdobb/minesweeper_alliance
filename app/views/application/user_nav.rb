# frozen_string_literal: true

# Application::UserNav represents the right side of the nav bar, where the
# {User#display_name} is displayed for {User}s that have signed their name.
class Application::UserNav
  def initialize(current_user:)
    @current_user = current_user
  end

  def turbo_frame_name
    [current_user, :user_nav]
  end

  def signer? = current_user.signer?

  def user_url
    Router.user_path(current_user)
  end

  def display_name = current_user.display_name

  private

  attr_reader :current_user
end
