# frozen_string_literal: true

# Application::UserNav
class Application::UserNav
  def initialize(current_user:)
    @current_user = current_user
  end

  def turbo_frame_name
    [current_user, :nav]
  end

  def signer? = current_user.signer?

  def user_url
    Router.user_path(current_user)
  end

  def display_name = current_user.display_name

  private

  attr_reader :current_user
end
