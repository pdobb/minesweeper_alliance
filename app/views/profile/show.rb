# frozen_string_literal: true

# Profile::Show
class Profile::Show
  def initialize(user:)
    @user = user
  end

  def display_name = user.display_name

  def reset_profile_url = Router.profile_path

  def authentication_url
    Router.profile_authentication_path(token:)
  end

  private

  attr_reader :user

  def token = user.authentication_token
end
