# frozen_string_literal: true

# Application::UserNav represents the right side of the nav bar, where the
# {User}'s username / profile link is displayed--for active participants.
class Application::UserNav
  def initialize(current_user:)
    @current_user = current_user
  end

  def turbo_frame_name
    [current_user, :user_nav]
  end

  def participant? = current_user.active_participant?

  def profile_url
    Router.profile_path
  end

  def turbo_update_id = View.dom_id(current_user)
  def display_name = current_user.username

  private

  attr_reader :current_user
end
